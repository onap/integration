/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
 * ================================================================================
 * Copyright (C) 2018 Nokia. All rights reserved.
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

import org.apache.http.client.HttpClient;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.conn.ssl.TrustAllStrategy;
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
import org.apache.http.conn.ssl.TrustStrategy;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.ssl.SSLContextBuilder;
import org.apache.http.ssl.SSLContexts;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.net.ssl.SSLContext;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.GeneralSecurityException;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.util.Optional;

public enum SslSupportLevel {

    NONE {
        public HttpClient getClient(RequestConfig requestConfig, SSLAuthenticationHelper sslAuthenticationHelper) {
            LOGGER.info("<!-----IN SslSupportLevel.NONE, Creating BasicHttpClient for http protocol----!>");
            return HttpClientBuilder
                    .create()
                    .setDefaultRequestConfig(requestConfig)
                    .build();
        }
    },
    ALWAYS_TRUST {
        public HttpClient getClient(RequestConfig requestConfig, SSLAuthenticationHelper sslAuthenticationHelper)
                throws GeneralSecurityException, IOException {
            LoggerFactory.getLogger(SslSupportLevel.class).info("<!-----IN SslSupportLevel.ALWAYS_TRUST, Creating client with SSL support for https protocol----!>");
            HttpClient client;
            try {
                SSLContext alwaysTrustSslContext = SSLContextBuilder.create().loadTrustMaterial(TRUST_STRATEGY_ALWAYS).build();
                client = HttpClients.custom()
                        .setSSLContext(alwaysTrustSslContext)
                        .setSSLHostnameVerifier(new NoopHostnameVerifier())
                        .setDefaultRequestConfig(requestConfig)
                        .build();

            } catch (GeneralSecurityException e) {
                LOGGER.error("Could not initialize client due to SSL exception: {}. Default client without SSL support will be used instead.\nCause: {}", e.getMessage(), e.getCause());
                client = NONE.getClient(requestConfig, sslAuthenticationHelper);
            }
            return client;
        }
    },
    CLIENT_CERT_AUTH {
        @Override
        public HttpClient getClient(RequestConfig requestConfig, SSLAuthenticationHelper sslAuthenticationHelper)
                throws GeneralSecurityException, IOException {

            SSLContext sslContext = SSLContexts.custom()
                    .loadKeyMaterial(readCertificate(sslAuthenticationHelper.getClientCertificateDir(), sslAuthenticationHelper.getClientCertificatePassword(), "PKCS12"), getPasswordAsCharArray(sslAuthenticationHelper.getClientCertificatePassword()))
                    .loadTrustMaterial(readCertificate(sslAuthenticationHelper.getTrustStoreDir(), sslAuthenticationHelper.getTrustStorePassword(), "JKS"), new TrustSelfSignedStrategy())
                    .build();

            return HttpClients.custom()
                    .setSSLContext(sslContext)
                    .setSSLHostnameVerifier(new NoopHostnameVerifier())
                    .setDefaultRequestConfig(requestConfig)
                    .build();
        }

        private KeyStore readCertificate(String certificate, String password, String type) throws GeneralSecurityException, IOException {
            try (InputStream keyStoreStream = new FileInputStream(certificate)) {
                KeyStore keyStore = KeyStore.getInstance(type);
                keyStore.load(keyStoreStream, getPasswordAsCharArray(password));
                return keyStore;
            }
        }

        private char[] getPasswordAsCharArray(String clientCertificatePassword) {
            return Optional.ofNullable(clientCertificatePassword).map(String::toCharArray).orElse(null);
        }
    };

    private static final Logger LOGGER = LoggerFactory.getLogger(SslSupportLevel.class);
    private static final TrustStrategy TRUST_STRATEGY_ALWAYS = new TrustAllStrategy();

    public static SslSupportLevel getSupportLevelBasedOnProtocol(String url) throws MalformedURLException {
        return "https".equals(new URL(url).getProtocol()) ? SslSupportLevel.ALWAYS_TRUST : SslSupportLevel.NONE;
    }

    public abstract HttpClient getClient(RequestConfig config, SSLAuthenticationHelper sslAuthenticationHelper)
            throws GeneralSecurityException, IOException;

}
