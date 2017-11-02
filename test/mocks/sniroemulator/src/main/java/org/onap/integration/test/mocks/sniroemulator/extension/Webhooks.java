/*-
 * ============LICENSE_START=======================================================
 * org.onap.integration
 * ================================================================================
 * Copyright (C) 2017 AT&T Intellectual Property. All rights reserved.
 * ================================================================================
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============LICENSE_END=========================================================
 */
package org.onap.integration.test.mocks.sniroemulator.extension;

import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.JsonNode;
import com.github.tomakehurst.wiremock.common.Notifier;
import com.github.tomakehurst.wiremock.core.Admin;
import com.github.tomakehurst.wiremock.extension.Parameters;
import com.github.tomakehurst.wiremock.extension.PostServeAction;
import com.github.tomakehurst.wiremock.http.HttpClientFactory;
import com.github.tomakehurst.wiremock.http.HttpHeader;
import com.github.tomakehurst.wiremock.stubbing.ServeEvent;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpEntityEnclosingRequestBase;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.util.EntityUtils;
import com.github.tomakehurst.wiremock.common.Json;


import java.io.IOException;
import java.util.Map;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;

import static com.github.tomakehurst.wiremock.common.Exceptions.throwUnchecked;
import static com.github.tomakehurst.wiremock.common.LocalNotifier.notifier;
import static com.github.tomakehurst.wiremock.http.HttpClientFactory.getHttpRequestFor;
import static java.util.concurrent.TimeUnit.SECONDS;

public class Webhooks extends PostServeAction {

    private final ScheduledExecutorService scheduler;
    private final HttpClient httpClient;
    private String tunnelResourceId = "NONE";
    private String brgResourceId = "NONE";
    private String vgResourceId = "NONE";

    public Webhooks() {
        scheduler = Executors.newScheduledThreadPool(10);
        httpClient = HttpClientFactory.createClient();
    }

    @Override
    public String getName() {
        return "webhook";
    }

    @Override
    public void doAction(ServeEvent serveEvent, Admin admin, Parameters parameters) {
        final WebhookDefinition definition = parameters.as(WebhookDefinition.class);
        final Notifier notifier = notifier();


        scheduler.schedule(
            new Runnable() {
                @Override
                public void run() {
                    JsonNode node = Json.node(serveEvent.getRequest().getBodyAsString());
               // set callback url from SO request
                    String callBackUrl = node.get("requestInfo").get("callbackUrl").asText();
                    notifier.info("!!! Call Back Url : \n" + callBackUrl);
                    definition.withUrl(callBackUrl);

               // set servicesResourceIds for each resource from SO request placement Demand
                    //System.out.println ("PI: \n" + node.textValue());
                    JsonNode placementDemandList = node.get("placementInfo").get("demandInfo").get("placementDemand");
                    if (placementDemandList !=null  &&  placementDemandList.isArray()){
                        for (int i=0;i<placementDemandList.size();i++){
                             JsonNode resourceInfo  = placementDemandList.get(i);
                             String resourceModuleName = resourceInfo.get("resourceModuleName").asText();
                             if (resourceModuleName.toLowerCase().matches("(.*)tunnel(.*)")){
                                 tunnelResourceId = resourceInfo.get("serviceResourceId").asText();
                             } else if (resourceModuleName.toLowerCase().matches("(.*)brg(.*)")) {
                                 brgResourceId = resourceInfo.get("serviceResourceId").asText();
                             }else {
                                 vgResourceId = resourceInfo.get("serviceResourceId").asText();
                             }
                        }
                    }

                    String stubbedBodyStr = definition.getBase64BodyAsString();
                    String newBodyStr = stubbedBodyStr.replace("TUNNEL-RESOURCE-ID-REPLACE",tunnelResourceId).replace("VGW-RESOURCE-ID-REPLACE",vgResourceId).replace("BRG-RESOURCE-ID-REPLACE",brgResourceId);

                    definition.withBody(newBodyStr);
                    notifier.info("SNIRO Async Callback response:\n" + definition.getBody());

                    HttpUriRequest request = buildRequest(definition);

                    try {
                        HttpResponse response = httpClient.execute(request);
                        notifier.info(
                            String.format("Webhook %s request to %s returned status %s\n\n%s",
                                definition.getMethod(),
                                definition.getUrl(),
                                response.getStatusLine(),
                                EntityUtils.toString(response.getEntity())
                            )                            
                        );
                        //System.out.println(String.format("Webhook %s request to %s returned status %s\n\n%s",
                        //        	definition.getMethod(),
                        //        	definition.getUrl(),
                        //        	response.getStatusLine(),
                        //        	EntityUtils.toString(response.getEntity())
                        //		)
                        //);
                    } catch (IOException e) {
                        e.printStackTrace();
                        throwUnchecked(e);
                    }
                }
            },
            0L,
            SECONDS
        );
    }

    private static HttpUriRequest buildRequest(WebhookDefinition definition) {
        HttpUriRequest request = getHttpRequestFor(
                definition.getMethod(),
                definition.getUrl().toString()
        );


        for (HttpHeader header: definition.getHeaders().all()) {
            request.addHeader(header.key(), header.firstValue());
        }

        if (definition.getMethod().hasEntity()) {
            HttpEntityEnclosingRequestBase entityRequest = (HttpEntityEnclosingRequestBase) request;
            entityRequest.setEntity(new ByteArrayEntity(definition.getBinaryBody()));
        }

        return request;
    }

    public static WebhookDefinition webhook() {
        return new WebhookDefinition();
    }
}
