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

package org.onap.pnfsimulator.integration.suites;

import com.palantir.docker.compose.DockerComposeRule;
import com.palantir.docker.compose.connection.waiting.HealthChecks;
import org.junit.ClassRule;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.junit.runners.Suite.SuiteClasses;
import org.onap.pnfsimulator.integration.BasicAvailabilityTest;
import org.onap.pnfsimulator.integration.OptionalTemplatesTest;
import org.onap.pnfsimulator.integration.SearchInTemplatesTest;
import org.onap.pnfsimulator.integration.TemplatesManagementTest;

@RunWith(Suite.class)
@SuiteClasses({BasicAvailabilityTest.class, TemplatesManagementTest.class, OptionalTemplatesTest.class,
    SearchInTemplatesTest.class})
public class DockerBasedTestsSuite {

    @ClassRule
    public static DockerComposeRule docker = DockerComposeRule.builder()
        .file("../docker-compose.yml")
        .waitingForService("pnf-simulator", HealthChecks.toHaveAllPortsOpen())
        .waitingForService("mongo", HealthChecks.toHaveAllPortsOpen())
        .build();

}
