/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
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
package org.onap.pnfsimulator.simulator.client.utils.ssl;

import java.io.Serializable;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "ssl")
@RefreshScope
@Primary
public class SSLAuthenticationHelper implements Serializable {

    private boolean clientCertificateEnabled;
    private String clientCertificateDir;
    private String clientCertificatePassword;
    private String trustStoreDir;
    private String trustStorePassword;

    public boolean isClientCertificateEnabled() {
        return clientCertificateEnabled;
    }

    public void setClientCertificateEnabled(boolean clientCertificateEnabled) {
        this.clientCertificateEnabled = clientCertificateEnabled;
    }

    public String getClientCertificateDir() {
        return clientCertificateDir;
    }

    public void setClientCertificateDir(String clientCertificateDir) {
        this.clientCertificateDir = clientCertificateDir;
    }

    public String getClientCertificatePassword() {
        return clientCertificatePassword;
    }

    public void setClientCertificatePassword(String clientCertificatePassword) {
        this.clientCertificatePassword = clientCertificatePassword;
    }

    public String getTrustStoreDir() {
        return trustStoreDir;
    }

    public void setTrustStoreDir(String trustStoreDir) {
        this.trustStoreDir = trustStoreDir;
    }

    public String getTrustStorePassword() {
        return trustStorePassword;
    }

    public void setTrustStorePassword(String trustStorePassword) {
        this.trustStorePassword = trustStorePassword;
    }
}
