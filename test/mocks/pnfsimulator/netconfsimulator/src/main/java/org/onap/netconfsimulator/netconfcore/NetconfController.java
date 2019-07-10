/*
 * ============LICENSE_START=======================================================
 * NETCONF-CONTROLLER
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

package org.onap.netconfsimulator.netconfcore;

import com.tailf.jnc.JNCException;

import java.io.IOException;

import lombok.extern.slf4j.Slf4j;
import org.onap.netconfsimulator.netconfcore.configuration.NetconfConfigurationService;
import org.onap.netconfsimulator.netconfcore.model.LoadModelResponse;
import org.onap.netconfsimulator.netconfcore.model.NetconfModelLoaderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RestController
@RequestMapping("netconf")
class NetconfController {

    private final NetconfConfigurationService netconfService;
    private final NetconfModelLoaderService netconfModelLoaderService;

    @Autowired
    NetconfController(NetconfConfigurationService netconfService,
                      NetconfModelLoaderService netconfModelLoaderService) {
        this.netconfService = netconfService;
        this.netconfModelLoaderService = netconfModelLoaderService;
    }

    @GetMapping(value = "get", produces = "application/xml")
    ResponseEntity<String> getNetconfConfiguration() throws IOException, JNCException {
        return ResponseEntity.ok(netconfService.getCurrentConfiguration());
    }

    @GetMapping(value = "get/{model}/{container}", produces = "application/xml")
    ResponseEntity<String> getNetconfConfiguration(@PathVariable String model,
                                                   @PathVariable String container)
            throws IOException {
        ResponseEntity<String> entity;
        try {
            entity = ResponseEntity.ok(netconfService.getCurrentConfiguration(model, container));
        } catch (JNCException exception) {
            log.error("Get configuration for model {} and container {} failed.", model, container,
                    exception);
            entity = ResponseEntity.badRequest().body(exception.toString());
        }
        return entity;
    }

    @PostMapping(value = "edit-config", produces = "application/xml")
    @ResponseStatus(HttpStatus.ACCEPTED)
    ResponseEntity<String> editConfig(@RequestPart("editConfigXml") MultipartFile editConfig)
            throws IOException, JNCException {
        log.info("Loading updated configuration");
        if (editConfig == null || editConfig.isEmpty()) {
            throw new IllegalArgumentException("No XML file with proper name: editConfigXml found.");
        }
        return ResponseEntity
                .status(HttpStatus.ACCEPTED)
                .body(netconfService.editCurrentConfiguration(editConfig));
    }

    @PostMapping("model/{moduleName}")
    ResponseEntity<String> loadNewYangModel(@RequestBody MultipartFile yangModel,
                                            @RequestBody MultipartFile initialConfig, @PathVariable String moduleName)
            throws IOException {
        LoadModelResponse response = netconfModelLoaderService.loadYangModel(yangModel, initialConfig, moduleName);
        return ResponseEntity
                .status(response.getStatusCode())
                .body(response.getMessage());
    }

    @DeleteMapping("model/{modelName}")
    ResponseEntity<String> deleteYangModel(@PathVariable String modelName)
            throws IOException {
        LoadModelResponse response = netconfModelLoaderService.deleteYangModel(modelName);
        return ResponseEntity
                .status(response.getStatusCode())
                .body(response.getMessage());
    }
}
