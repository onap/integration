/*-
 * ============LICENSE_START=======================================================
 * Simulator
 * ================================================================================
 * Copyright (C) 2019 Nokia. All rights reserved.
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

package integration;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpDelete;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.junit.platform.commons.logging.Logger;
import org.junit.platform.commons.logging.LoggerFactory;
import org.springframework.util.ResourceUtils;

import java.io.IOException;
import java.time.Duration;
import java.time.Instant;

class NetconfSimulatorClient {

    private CloseableHttpClient netconfClient;
    private String simulatorBaseUrl;
    private static final Logger LOG = LoggerFactory.getLogger(NetconfSimulatorClient.class);

    NetconfSimulatorClient(String simulatorBaseUrl) {
        this.netconfClient  = HttpClients.createDefault();
        this.simulatorBaseUrl = simulatorBaseUrl;
    }

    CloseableHttpResponse loadModel(String moduleName, String yangModelFileName, String initialiConfigFileName) throws IOException {
        String updateConfigUrl = String.format("%s/netconf/model/%s", simulatorBaseUrl, moduleName);
        HttpPost httpPost = new HttpPost(updateConfigUrl);
        HttpEntity updatedConfig = MultipartEntityBuilder
                .create()
                .addBinaryBody("yangModel", ResourceUtils.getFile(String.format("classpath:%s", yangModelFileName)))
                .addBinaryBody("initialConfig", ResourceUtils.getFile(String.format("classpath:%s",initialiConfigFileName)))
                .addTextBody("moduleName", moduleName)
                .build();
        httpPost.setEntity(updatedConfig);
        return netconfClient.execute(httpPost);
    }

    CloseableHttpResponse deleteModel(String moduleName) throws IOException {
        String deleteModuleUrl = String.format("%s/netconf/model/%s", simulatorBaseUrl, moduleName);
        HttpDelete httpDelete = new HttpDelete(deleteModuleUrl);
        return netconfClient.execute(httpDelete);
    }

    boolean isServiceAvailable(Instant startTime, Duration maxWaitingDuration) throws InterruptedException {
        boolean isServiceReady = false;
        while (Duration.between(startTime, Instant.now()).compareTo(maxWaitingDuration) < 1){
            if(checkIfSimResponds()){
                return true;
            }
            else {
                LOG.info(() -> "Simulator not ready yet, retrying in 5s...");
                Thread.sleep(5000);
            }
        }
        return isServiceReady;
    }

    private boolean checkIfSimResponds() throws InterruptedException {
        try(CloseableHttpResponse pingResponse = getCurrentConfig()){
            String responseString = getResponseContentAsString(pingResponse);
            if(pingResponse.getStatusLine().getStatusCode() == 200 && !responseString.trim().isEmpty()){
                return true;
            }
        }
        catch(IOException ex){
            LOG.error(ex, () -> "EXCEPTION");
            Thread.sleep(5000);
        }
        return false;
    }

    CloseableHttpResponse getCurrentConfig() throws IOException {
        String netconfAddress = String.format("%s/netconf/get", simulatorBaseUrl);
        HttpGet get = new HttpGet(netconfAddress);
        return netconfClient.execute(get);
    }

    CloseableHttpResponse getConfigByModelAndContainerNames(String model, String container) throws IOException {
        String netconfAddress = String
            .format("%s/netconf/get/%s/%s", simulatorBaseUrl, model, container);
        HttpGet get = new HttpGet(netconfAddress);
        return netconfClient.execute(get);
    }

    CloseableHttpResponse updateConfig() throws IOException {
        String updateConfigUrl = String.format("%s/netconf/edit-config", simulatorBaseUrl);
        HttpPost httpPost = new HttpPost(updateConfigUrl);
        HttpEntity updatedConfig = MultipartEntityBuilder
                .create()
                .addBinaryBody("editConfigXml", ResourceUtils.getFile("classpath:updatedConfig.xml"))
                .build();
        httpPost.setEntity(updatedConfig);
        return netconfClient.execute(httpPost);
    }

    CloseableHttpResponse getAllConfigChanges() throws IOException {
        String netconfStoreCmHistoryAddress = String.format("%s/store/cm-history", simulatorBaseUrl);
        HttpGet configurationChangesResponse = new HttpGet(netconfStoreCmHistoryAddress);
        return netconfClient.execute(configurationChangesResponse);
    }

    CloseableHttpResponse getLastConfigChanges(int howManyLastChanges) throws IOException {
        String netconfStoreCmHistoryAddress = String.format("%s/store/less?offset=%d", simulatorBaseUrl, howManyLastChanges);
        HttpGet configurationChangesResponse = new HttpGet(netconfStoreCmHistoryAddress);
        return netconfClient.execute(configurationChangesResponse);
    }

    void releaseClient() throws IOException {
        netconfClient.close();
    }

    void reinitializeClient(){
        netconfClient = HttpClients.createDefault();
    }

    String getResponseContentAsString(HttpResponse response) throws IOException {
        HttpEntity entity = response.getEntity();
        String entityStringRepr = EntityUtils.toString(entity);
        EntityUtils.consume(entity);
        return entityStringRepr;
    }

}
