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

package org.onap.pnfsimulator.integration;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RequestMapping("ves-simulator")
@RestController
public class VesSimulatorController {

    private final VesSimulatorService vesSimulatorService;
    private final Gson gson;

    @Autowired
    public VesSimulatorController(VesSimulatorService vesSimulatorService, Gson gson) {
        this.vesSimulatorService = vesSimulatorService;
        this.gson = gson;
    }

    @PostMapping("eventListener/v5")
    String sendEventToDmaapV5(@RequestBody String body) {
        System.out.println("Received event" + body);
        JsonObject jsonObject = gson.fromJson(body, JsonObject.class);
        vesSimulatorService.sendEventToDmaapV5(jsonObject);
        return "MessageAccepted";
    }

    @PostMapping("eventListener/v7")
    String sendEventToDmaapV7(@RequestBody String body) {
        System.out.println("Received event" + body);
        JsonObject jsonObject = gson.fromJson(body, JsonObject.class);
        vesSimulatorService.sendEventToDmaapV7(jsonObject);
        return "MessageAccepted";
    }
}
