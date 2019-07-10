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

import static org.assertj.core.api.Java6Assertions.assertThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.onap.pnfsimulator.rest.TemplateController.CANNOT_OVERRIDE_TEMPLATE_MSG;
import static org.onap.pnfsimulator.rest.TemplateController.TEMPLATE_NOT_FOUND_MSG;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.assertj.core.util.Lists;
import org.bson.Document;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import static org.mockito.Mockito.times;
import org.mockito.MockitoAnnotations;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.rest.model.SearchExp;
import org.onap.pnfsimulator.template.Template;
import org.onap.pnfsimulator.template.search.IllegalJsonValueException;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class TemplateControllerTest {

    private static final String LIST_URL = "/template/list";
    private static final String GET_FORMAT_STR = "/template/get/%s";
    private static final String SEARCH_ENDPOINT = "/template/search";
    private static final String UPLOAD_URL_NOFORCE = "/template/upload";
    private static final String UPLOAD_URL_FORCE = "/template/upload?override=true";
    private static final String SAMPLE_TEMPLATE_JSON = "{\"event\": {\n"
        + "    \"commonEventHeader\": {\n"
        + "      \"domain\": \"measurementsForVfScaling\",\n"
        + "      \"eventName\": \"vFirewallBroadcastPackets\",\n"
        + "   }"
        + "}}";

    public static final String TEMPLATE_REQUEST = "{\n"
        + " \"name\": \"someTemplate\",\n"
        + " \"template\": {\n"
        + "  \"commonEventHeader\": {\n"
        + "   \"domain\": \"notification\",\n"
        + "   \"eventName\": \"vFirewallBroadcastPackets\"\n"
        + "  },\n"
        + "  \"notificationFields\": {\n"
        + "   \"arrayOfNamedHashMap\": [{\n"
        + "    \"name\": \"A20161221.1031-1041.bin.gz\",\n"
        + "\n"
        + "    \"hashMap\": {\n"
        + "     \"fileformatType\": \"org.3GPP.32.435#measCollec\"\n"
        + "    }\n"
        + "   }]\n"
        + "  }\n"
        + " }\n"
        + "}";
    private static final Document SAMPLE_TEMPLATE_BSON = Document.parse(SAMPLE_TEMPLATE_JSON);
    private static final List<String> SAMPLE_TEMPLATE_NAME_LIST = Lists.newArrayList("notification.json", "registration.json");
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private static final Gson GSON_OBJ = new GsonBuilder().create();
    private MockMvc mockMvc;

    @Mock
    private Storage<Template> templateService;
    @InjectMocks
    private TemplateController controller;

    @BeforeEach
    void setup() {
        MockitoAnnotations.initMocks(this);
        mockMvc = MockMvcBuilders
            .standaloneSetup(controller)
            .build();
    }

    @Test
    void shouldGetAllTemplates() throws Exception {
        List<Template> templateList = createTemplatesList();
        when(templateService.getAll()).thenReturn(templateList);

        MvcResult getResult = mockMvc
            .perform(get(LIST_URL)
                .accept(MediaType.APPLICATION_JSON))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andReturn();

        Type listType = new TypeToken<ArrayList<Template>>() {}.getType();
        List<Template> resultList = GSON_OBJ.fromJson(getResult.getResponse().getContentAsString(), listType);
        assertThat(resultList).containsExactlyInAnyOrderElementsOf(templateList);
    }

    @Test
    void shouldListEmptyCollectionWhenNoTemplatesAvailable() throws Exception {
        List<Template> templateList = Collections.emptyList();
        when(templateService.getAll()).thenReturn(templateList);

        MvcResult getResult = mockMvc
            .perform(get(LIST_URL))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andReturn();

        String templatesAsString = GSON_OBJ.toJson(templateList);
        assertThat(getResult.getResponse().getContentAsString()).containsSequence(templatesAsString);
    }

    @Test
    void shouldSuccessfullyGetExisitngTemplateByName() throws Exception {
        String sampleTemplateName = "someTemplate";
        String requestUrl = String.format(GET_FORMAT_STR, sampleTemplateName);
        Template sampleTemplate = new Template(sampleTemplateName, SAMPLE_TEMPLATE_BSON, 0L);

        when(templateService.get(sampleTemplateName)).thenReturn(Optional.of(sampleTemplate));

        MvcResult getResult = mockMvc
            .perform(get(requestUrl))
            .andExpect(status().isOk())
            .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
            .andReturn();

        Template result = new Gson().fromJson(getResult.getResponse().getContentAsString(), Template.class);
        assertThat(result).isEqualTo(sampleTemplate);
    }

    @Test
    void shouldReturnNotFoundWhenGetNonExisitngTemplateByName() throws Exception {
        String sampleTemplateName = "doesNotExist";
        String requestUrl = String.format(GET_FORMAT_STR, sampleTemplateName);

        when(templateService.get(sampleTemplateName)).thenReturn(Optional.empty());

        MvcResult getResult = mockMvc
            .perform(get(requestUrl))
            .andExpect(status().isNotFound())
            .andExpect(content().contentType(MediaType.TEXT_PLAIN_VALUE))
            .andReturn();

        assertThat(getResult.getResponse().getContentLength()).isEqualTo(TEMPLATE_NOT_FOUND_MSG.length());
    }


    @Test
    void shouldReturnNamesOfTemplatesThatSatisfyGivenCriteria() throws Exception {
        when(templateService.getIdsByContentCriteria(any(JsonObject.class))).thenReturn(SAMPLE_TEMPLATE_NAME_LIST);
        SearchExp expr = new SearchExp(new JsonObject());

        String responseContent = mockMvc
                .perform(post(SEARCH_ENDPOINT).content(GSON_OBJ.toJson(expr)).contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
                .andReturn().getResponse().getContentAsString();

        List<String> actualTemplates = OBJECT_MAPPER.readValue(responseContent, new TypeReference<List<String>>() {});
        verify(templateService, times(1)).getIdsByContentCriteria(any(JsonObject.class));
        assertThat(actualTemplates).isEqualTo(SAMPLE_TEMPLATE_NAME_LIST);
    }

    @Test
    void shouldRaiseBadRequestWhenNullValueProvidedInSearchJsonAsJsonValue() throws Exception {
        when(templateService.getIdsByContentCriteria(any(JsonObject.class))).thenThrow(IllegalJsonValueException.class);
        SearchExp expr = new SearchExp(new JsonObject());

        mockMvc.perform(post(SEARCH_ENDPOINT)
                .content(GSON_OBJ.toJson(expr))
                .contentType(MediaType.APPLICATION_JSON_UTF8_VALUE))
                .andExpect(status().isBadRequest());
    }


    @Test
    void testTryUploadNewTemplate() throws Exception {
        when(templateService.tryPersistOrOverwrite(any(Template.class), eq(false))).thenReturn(true);

        MvcResult postResult = mockMvc
            .perform(post(UPLOAD_URL_NOFORCE)
                .contentType(MediaType.APPLICATION_JSON_UTF8_VALUE)
                .content(TEMPLATE_REQUEST))
            .andExpect(status().isCreated())
            .andReturn();
    }

    @Test
    void testTryUploadNewTemplateWithForce() throws Exception {
        when(templateService.tryPersistOrOverwrite(any(Template.class), eq(true))).thenReturn(true);

        MvcResult postResult = mockMvc
            .perform(post(UPLOAD_URL_FORCE)
                .contentType(MediaType.APPLICATION_JSON_UTF8_VALUE)
                .content(TEMPLATE_REQUEST))
            .andExpect(status().isCreated())
            .andReturn();
    }

    @Test
    void testOverrideExistingTemplateWithoutForceShouldFail() throws Exception {
        when(templateService.tryPersistOrOverwrite(any(Template.class), eq(true))).thenReturn(false);

        MvcResult postResult = mockMvc
            .perform(post(UPLOAD_URL_FORCE)
                .contentType(MediaType.APPLICATION_JSON_UTF8_VALUE)
                .content(TEMPLATE_REQUEST))
            .andExpect(status().isConflict())
            .andReturn();

        assertThat(postResult.getResponse().getContentAsString()).isEqualTo(CANNOT_OVERRIDE_TEMPLATE_MSG);
    }

    private List<Template> createTemplatesList() {
        return Arrays.asList(
            new Template("1", SAMPLE_TEMPLATE_BSON, 0L),
            new Template("2", SAMPLE_TEMPLATE_BSON, 0L),
            new Template("3", SAMPLE_TEMPLATE_BSON, 0L));
    }
}
