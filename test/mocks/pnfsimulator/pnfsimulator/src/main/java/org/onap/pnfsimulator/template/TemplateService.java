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

package org.onap.pnfsimulator.template;

import java.util.List;
import java.util.Optional;

import com.google.gson.JsonObject;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.template.search.TemplateSearchHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

@Primary
@Service
public class TemplateService implements Storage<Template> {

    private final TemplateRepository templateRepository;
    private TemplateSearchHelper searchHelper;


    @Autowired
    public TemplateService(TemplateRepository templateRepository, TemplateSearchHelper searchHelper) {
        this.templateRepository = templateRepository;
        this.searchHelper = searchHelper;
    }

    @Override
    public List<Template> getAll() {
        return templateRepository.findAll();
    }

    @Override
    public Optional<Template> get(String name) {
        return templateRepository.findById(name);
    }

    @Override
    public void persist(Template template) {
        templateRepository.save(template);
    }

    @Override
    public boolean tryPersistOrOverwrite(Template template, boolean overwrite) {
        if (templateRepository.existsById(template.getId()) && !overwrite) {
            return false;
        }
        templateRepository.save(template);
        return true;
    }

    @Override
    public void delete(String templateName) {
        templateRepository.deleteById(templateName);
    }

    @Override
    public List<String> getIdsByContentCriteria(JsonObject stringQueryJson) {
        return searchHelper.getIdsOfDocumentMatchingCriteria(stringQueryJson);
    }

}
