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

package org.onap.netconfsimulator.kafka;

import java.util.List;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
@RequestMapping("/store")
public class StoreController {

    private StoreService service;

    @Autowired
    public StoreController(StoreService service) {
        this.service = service;
    }

    @GetMapping("/ping")
    String ping() {
        return "pong";
    }

    @GetMapping("cm-history")
    List<MessageDTO> getAllConfigurationChanges() {
        return service.getAllMessages();
    }

    @GetMapping("/less")
    List<MessageDTO> less(@RequestParam(value = "offset", required = false, defaultValue = "${spring.kafka.default-offset}") long offset) {
        return service.getLastMessages(offset);
    }

}
