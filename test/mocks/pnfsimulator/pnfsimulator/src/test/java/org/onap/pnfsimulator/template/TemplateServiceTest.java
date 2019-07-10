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

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.assertj.core.util.Lists;
import org.bson.Document;
import org.junit.Assert;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;;
import org.onap.pnfsimulator.template.search.viewmodel.FlatTemplateContent;
import org.onap.pnfsimulator.template.search.TemplateSearchHelper;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;

import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyObject;
import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;

class TemplateServiceTest {
    private static final Gson GSON = new Gson();
    private static final Template SAMPLE_TEMPLATE = new Template("sample name", new Document(), Instant.now().getNano());
    private static final List<Template> SAMPLE_TEMPLATE_LIST = Collections.singletonList(SAMPLE_TEMPLATE);

    @Mock
    private TemplateRepository templateRepositoryMock;

    @Mock
    private MongoTemplate mongoTemplate;

    @InjectMocks
    private TemplateService service;

    @BeforeEach
    void setUp() {
        initMocks(this);
        TemplateSearchHelper searchHelper = new TemplateSearchHelper(mongoTemplate);
        service = new TemplateService(templateRepositoryMock, searchHelper);
    }

    @Test
    void testShouldReturnAllTemplates() {
        when(templateRepositoryMock.findAll()).thenReturn(SAMPLE_TEMPLATE_LIST);

        List<Template> actual = service.getAll();
        assertThat(actual).containsExactly(SAMPLE_TEMPLATE_LIST.get(0));
    }


    @Test
    void testShouldGetTemplateBySpecifiedName() {
        when(templateRepositoryMock.findById("sample name")).thenReturn(Optional.of(SAMPLE_TEMPLATE));

        Optional<Template> actualTemplate = service.get("sample name");
        assertThat(actualTemplate).isPresent();
        assertThat(actualTemplate.get()).isEqualTo(SAMPLE_TEMPLATE);
    }

    @Test
    void testShouldSaveTemplate() {
        service.persist(SAMPLE_TEMPLATE);

        verify(templateRepositoryMock, times(1)).save(SAMPLE_TEMPLATE);
    }

    @Test
    void testShouldDeleteTemplateByName() {
        service.delete("sample name");

        verify(templateRepositoryMock, times(1)).deleteById("sample name");
    }


    @Test
    void testShouldReturnTemplatesAccordingToGivenSearchCriteria() {
        doReturn(Lists.emptyList()).when(mongoTemplate).find(any(Query.class), anyObject(), any(String.class));

        List<String> idsByContentCriteria = service.getIdsByContentCriteria(GSON.fromJson("{\"domain\": \"notification.json\"}", JsonObject.class));

        assertThat(idsByContentCriteria).isEmpty();
    }

    @Test
    void shouldReturnNamesForGivenComposedSearchCriteria(){
        JsonObject composedCriteriaObject = GSON.fromJson("{\"eventName\": \"pnfRegistration_Nokia_5gDu\", \"sequence\": 1}", JsonObject.class);
        List<FlatTemplateContent> arr = Lists.newArrayList(new FlatTemplateContent("sampleId", null));

        doReturn(arr).when(mongoTemplate).find(any(Query.class), anyObject(), any(String.class));

        List<String> idsByContentCriteria = service.getIdsByContentCriteria(composedCriteriaObject);
        assertThat(idsByContentCriteria).containsOnly("sampleId");
    }

    @Test
    void shouldReturnFalseWhenOverwritingWithoutForce() {
        String id = "someTemplate";
        Template template = new Template(id, new Document(), Instant.now().getNano());
        when(templateRepositoryMock.existsById(id)).thenReturn(true);
        boolean actual = service.tryPersistOrOverwrite(template, false);
        Assert.assertFalse(actual);
    }

    @Test
    void shouldReturnTrueWhenOverwritingWithForce() {
        String id = "someTemplate";
        Template template = new Template(id, new Document(), Instant.now().getNano());
        when(templateRepositoryMock.existsById(id)).thenReturn(true);
        boolean actual = service.tryPersistOrOverwrite(template, true);
        Assert.assertTrue(actual);
    }

    @Test
    void shouldReturnTrueWhenSavingNonExistingTemplate() {
        String id = "someTemplate";
        Template template = new Template(id, new Document(), Instant.now().getNano());
        when(templateRepositoryMock.existsById(id)).thenReturn(false);
        boolean actual = service.tryPersistOrOverwrite(template, false);
        Assert.assertTrue(actual);
    }

}
