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

package org.onap.pnfsimulator.rest;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import javax.validation.Valid;

import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.rest.model.TemplateRequest;
import org.onap.pnfsimulator.rest.model.SearchExp;
import org.onap.pnfsimulator.template.Template;
import org.onap.pnfsimulator.template.search.IllegalJsonValueException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;


@RestController
@RequestMapping("/template")
public class TemplateController {
    static final String TEMPLATE_NOT_FOUND_MSG = "A template with given name does not exist";
    static final String CANNOT_OVERRIDE_TEMPLATE_MSG = "Cannot overwrite existing template. Use override=true to override";
    private final Storage<Template> service;
    private static final Logger LOG = LoggerFactory.getLogger(TemplateController.class);

    @Autowired
    public TemplateController(Storage<Template> service) {
        this.service = service;
    }

    @GetMapping("list")
    public ResponseEntity<?> list() {
        return new ResponseEntity<>(service.getAll(), HttpStatus.OK);
    }

    @GetMapping("get/{templateName}")
    public ResponseEntity<?> get(@PathVariable String templateName) {
        Optional<Template> template = service.get(templateName);
        if (!template.isPresent()) {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.TEXT_PLAIN);
            return new ResponseEntity<>(TEMPLATE_NOT_FOUND_MSG, headers, HttpStatus.NOT_FOUND);
        }
        return new ResponseEntity<>(template, HttpStatus.OK);
    }

    @PostMapping("upload")
    public ResponseEntity<?> upload(
            @RequestBody @Valid TemplateRequest templateRequest,
            @RequestParam(required = false) boolean override) {
        String msg = "";
        HttpStatus status = HttpStatus.CREATED;
        Template template = new Template(templateRequest.getName(), templateRequest.getTemplate(), Instant.now().getNano());
        if (!service.tryPersistOrOverwrite(template, override)) {
            status = HttpStatus.CONFLICT;
            msg = CANNOT_OVERRIDE_TEMPLATE_MSG;
        }
        return new ResponseEntity<>(msg, status);
    }

    @PostMapping("search")
    public ResponseEntity<?> searchByCriteria(@RequestBody SearchExp queryJson) {
        try {
            List<String> templateNames = service.getIdsByContentCriteria(queryJson.getSearchExpr());
            return new ResponseEntity<>(templateNames, HttpStatus.OK);
        } catch (IllegalJsonValueException ex) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, String.format("Try again with correct parameters. Cause: %s", ex.getMessage()), ex);
        }

    }


}
