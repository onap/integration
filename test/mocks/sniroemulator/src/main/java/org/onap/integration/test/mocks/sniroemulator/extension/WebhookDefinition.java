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

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.github.tomakehurst.wiremock.http.Body;
import com.github.tomakehurst.wiremock.http.HttpHeader;
import com.github.tomakehurst.wiremock.http.HttpHeaders;
import com.github.tomakehurst.wiremock.http.RequestMethod;

import java.net.URI;
import java.util.List;

import static com.google.common.collect.Lists.newArrayList;

public class WebhookDefinition {
    
    private RequestMethod method;
    private URI url;
    private List<HttpHeader> headers;
    private Body body = Body.none();

    @JsonCreator
    public WebhookDefinition(@JsonProperty("method") RequestMethod method,
                             @JsonProperty("url") URI url,
                             @JsonProperty("headers") HttpHeaders headers,
                             @JsonProperty("body") String body,
                             @JsonProperty("base64Body") String base64Body) {
        this.method = method;
        this.url = url;
        this.headers = newArrayList(headers.all());
        this.body = Body.fromOneOf(null, body, null, base64Body);
    }

    public WebhookDefinition() {
    }

    public RequestMethod getMethod() {
        return method;
    }

    public URI getUrl() {
        return url;
    }

    public HttpHeaders getHeaders() {
        return new HttpHeaders(headers);
    }

    public String getBase64Body() {
        return body.isBinary() ? body.asBase64() : null;
    }

    public String getBody() {
        return body.isBinary() ? null : body.asString();
    }

    @JsonIgnore
    public byte[] getBinaryBody() {
        return body.asBytes();
    }

    public WebhookDefinition withMethod(RequestMethod method) {
        this.method = method;
        return this;
    }

    public WebhookDefinition withUrl(URI url) {
        this.url = url;
        return this;
    }

    public WebhookDefinition withUrl(String url) {
        withUrl(URI.create(url));
        return this;
    }

    public WebhookDefinition withHeaders(List<HttpHeader> headers) {
        this.headers = headers;
        return this;
    }

    public WebhookDefinition withHeader(String key, String... values) {
        if (headers == null) {
            headers = newArrayList();
        }

        headers.add(new HttpHeader(key, values));
        return this;
    }

    public WebhookDefinition withBody(String body) {
        this.body = new Body(body);
        return this;
    }

    public WebhookDefinition withBinaryBody(byte[] body) {
        this.body = new Body(body);
        return this;
    }
}
