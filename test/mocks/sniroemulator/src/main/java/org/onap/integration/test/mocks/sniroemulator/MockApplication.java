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

package org.onap.integration.test.mocks.sniroemulator;

import static com.github.tomakehurst.wiremock.client.ResponseDefinitionBuilder.responseDefinition;
import static com.github.tomakehurst.wiremock.client.WireMock.anyUrl;
import static com.github.tomakehurst.wiremock.core.WireMockApp.FILES_ROOT;
import static com.github.tomakehurst.wiremock.core.WireMockApp.MAPPINGS_ROOT;
import static com.github.tomakehurst.wiremock.http.RequestMethod.ANY;
import static com.github.tomakehurst.wiremock.matching.RequestPatternBuilder.newRequestPattern;
import static java.lang.System.out;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import com.github.tomakehurst.wiremock.WireMockServer;
import com.github.tomakehurst.wiremock.common.ConsoleNotifier;
import com.github.tomakehurst.wiremock.common.FatalStartupException;
import com.github.tomakehurst.wiremock.common.FileSource;
import com.github.tomakehurst.wiremock.core.WireMockConfiguration;
import com.github.tomakehurst.wiremock.http.ResponseDefinition;
import com.github.tomakehurst.wiremock.matching.RequestPattern;
import com.github.tomakehurst.wiremock.standalone.MappingsLoader;
import com.github.tomakehurst.wiremock.stubbing.StubMapping;
import com.github.tomakehurst.wiremock.stubbing.StubMappings;

@SpringBootApplication
public class MockApplication {

    
	private static final String BANNER= " \n" +
"          ********                                      ****     ****                        ##        \n" +
"         **######**                                     ###*     *###                        ##        \n" +
"        *##******##*                                    ##***   ***##                        ##\n" +
"	    **#*      *#**                                   ##*#*   *#*##                        ##        \n" +
"	    *#*        *#*  ##******   *******   ##******    ##*#*   *#*##    *******    ******   ##    *** \n" +
"	    *#*        *#*  ##*####*  *######*   ##*####**   ##*#*   *#*##   **#####**  **####**  ##   *#** \n" +
"	    *#*        *#*  ##****#*  *#****#*   ##** **#*   ## *** *** ##   *#** **#*  *#****#*  ## **#** \n" +
"	    *#          #*  ##*  *#*        #*   ##*   *#*   ## *#* *#* ##   *#*   *#*  *#*  *#*  ##**#** \n" +
"	    *#*        *#*  ##*   ##    ****##   ##*   *#*   ## *#* *#* ##   *#*   *#*  *#*       ##*##* \n" +	 
"	    *#*        *#*  ##    ##  **######   ##     #*   ## *#* *#* ##   *#     #*  *#        ##**#** \n" +
"	    *#*        *#*  ##    ##  *#****##   ##*   *#*   ##  *#*#*  ##   *#*   *#*  *#*       ##**##* \n" +
"	    **#*      *#**  ##    ##  *#*  *##   ##*   *#*   ##  *#*#*  ##   *#*   *#*  *#*  *#*  ##  *#** \n" +
"	     *##******##*   ##    ##  *#* **##*  ##** **#*   ##  *#*#*  ##   *#** **#*  *#****#*  ##  **#* \n" +
"	      **######**    ##    ##  *#######*  ##*####*    ##  *###*  ##   **#####**  **####**  ##   *#** \n" +
"	       ********     ##    ##  *******#*  ##******    ##   *#*   ##    *******    ******   ##    *#* \n" +
"                                            ##  \n" +
"                                            ##  \n" +
"                                            ##  \n" +
"                                            **  \n" ;
					
    static {
        System.setProperty("org.mortbay.log.class", "com.github.tomakehurst.wiremock.jetty.LoggerAdapter");
    }

	private WireMockServer wireMockServer;
	
	public static void main(String[] args) {
		SpringApplication.run(MockApplication.class, args);
		//new WireMockServerRunner().run("--port 9999");
		new MockApplication().run(args);
	}
	
	public void run(String... args) {

		WireMockConfiguration options = WireMockConfiguration.options();
        options.port(9999);
		FileSource fileSource = options.filesRoot();
		fileSource.createIfNecessary();
		FileSource filesFileSource = fileSource.child(FILES_ROOT);
		filesFileSource.createIfNecessary();
		FileSource mappingsFileSource = fileSource.child(MAPPINGS_ROOT);
		mappingsFileSource.createIfNecessary();
		
		// Register extension
		options.extensions("org.onap.integration.test.mocks.sniroemulator.extension.Webhooks");
		// Register notifier
        options.notifier(new ConsoleNotifier(true));
        wireMockServer = new WireMockServer(options);
        
        wireMockServer.enableRecordMappings(mappingsFileSource, filesFileSource);

		//if (options.specifiesProxyUrl()) {
		//	addProxyMapping(options.proxyUrl());
		//}

        try {
            wireMockServer.start();
            out.println(BANNER);
            out.println();
            out.println(options);
        } catch (FatalStartupException e) {
            System.err.println(e.getMessage());
            System.exit(1);
        }
    }
	
	private void addProxyMapping(final String baseUrl) {
		wireMockServer.loadMappingsUsing(new MappingsLoader() {
			@Override
			public void loadMappingsInto(StubMappings stubMappings) {
                RequestPattern requestPattern = newRequestPattern(ANY, anyUrl()).build();
				ResponseDefinition responseDef = responseDefinition()
						.proxiedFrom(baseUrl)
						.build();

				StubMapping proxyBasedMapping = new StubMapping(requestPattern, responseDef);
				proxyBasedMapping.setPriority(10); // Make it low priority so that existing stubs will take precedence
				stubMappings.addMapping(proxyBasedMapping);
			}
		});
	}
	
	public void stop() {
		wireMockServer.stop();
	}

    public boolean isRunning() {
        return wireMockServer.isRunning();
    }

    public int port() { return wireMockServer.port(); }	
	
}
