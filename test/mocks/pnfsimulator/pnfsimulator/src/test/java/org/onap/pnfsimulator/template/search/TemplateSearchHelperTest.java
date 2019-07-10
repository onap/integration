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

package org.onap.pnfsimulator.template.search;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.mongodb.BasicDBList;
import org.assertj.core.util.Lists;
import org.bson.Document;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.onap.pnfsimulator.template.search.viewmodel.FlatTemplateContent;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.BasicQuery;
import org.springframework.data.mongodb.core.query.Query;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static org.assertj.core.api.Java6Assertions.assertThat;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyObject;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;


class TemplateSearchHelperTest {

    private static final Gson GSON = new Gson();
    private static final String FLATTENED_TEMPLATES_VIEW = "flatTemplatesView";

    @Mock
    private MongoTemplate mongoTemplate;

    @InjectMocks
    private TemplateSearchHelper helper;

    private static final ArgumentCaptor<Query> QUERY_CAPTOR = ArgumentCaptor.forClass(Query.class);
    private static final ArgumentCaptor<String> COLLECTION_NAME_CAPTOR = ArgumentCaptor.forClass(String.class);
    private static final ArgumentCaptor<Class<FlatTemplateContent>> CLASS_TYPE_CAPTOR = ArgumentCaptor.forClass((Class) FlatTemplateContent.class);


    @BeforeEach
    void setUp() {
        initMocks(this);
    }

    @Test
    void shouldReturnNamesForGivenComposedSearchCriteria(){
        String expectedComposedQueryString = "{\"$and\":[{\"keyValues\":{\"$elemMatch\":{\"k\":{\"$regex\":\":eventName(?:(\\\\[[\\\\d]+\\\\]))?$\",\"$options\":\"iu\"},\"v\":{\"$regex\":\"^\\\\QpnfRegistration_Nokia_5gDu\\\\E$\",\"$options\":\"iu\"}}}},{\"keyValues\":{\"$elemMatch\":{\"k\":{\"$regex\":\":sequence(?:(\\\\[[\\\\d]+\\\\]))?$\",\"$options\":\"iu\"},\"v\":1.0}}}]}";
        Query expectedQuery = new BasicQuery(expectedComposedQueryString);

        String composedCriteriaInputJson = "{\"eventName\": \"pnfRegistration_Nokia_5gDu\", \"sequence\": 1}";
        JsonObject composedCriteriaObject = GSON.fromJson(composedCriteriaInputJson, JsonObject.class);

        when(mongoTemplate.find(any(Query.class), anyObject(), any(String.class))).thenReturn(Lists.newArrayList(new FlatTemplateContent("sampleId1", null), new FlatTemplateContent("sampleId2", null)));

        List<String> idsOfDocumentMatchingCriteria = helper.getIdsOfDocumentMatchingCriteria(composedCriteriaObject);

        assertThat(idsOfDocumentMatchingCriteria).containsOnly("sampleId1", "sampleId2");
        verify(mongoTemplate, times(1)).find(QUERY_CAPTOR.capture(), CLASS_TYPE_CAPTOR.capture(), COLLECTION_NAME_CAPTOR.capture());
        assertThat(QUERY_CAPTOR.getValue().toString()).isEqualTo(expectedQuery.toString());
        assertThat(COLLECTION_NAME_CAPTOR.getValue()).isEqualTo(FLATTENED_TEMPLATES_VIEW);
        assertThat(CLASS_TYPE_CAPTOR.getValue()).isEqualTo(FlatTemplateContent.class);
    }

    @Test
    void shouldReturnTemplatesAccordingToGivenSearchCriteria() {
        Query expectedQueryStructure = new BasicQuery("{\"$and\":[{\"keyValues\": { \"$elemMatch\" : { \"k\" : { \"$regex\" : \":domain(?:(\\\\[[\\\\d]+\\\\]))?$\", \"$options\" : \"iu\" }, \"v\" : { \"$regex\" : \"^\\\\Qnotification\\\\E$\", \"$options\" : \"iu\" }}}}]}");

        helper.getIdsOfDocumentMatchingCriteria(GSON.fromJson("{\"domain\": \"notification\"}", JsonObject.class));


        verify(mongoTemplate, times(1)).find(QUERY_CAPTOR.capture(), CLASS_TYPE_CAPTOR.capture(), COLLECTION_NAME_CAPTOR.capture());

        assertThat(QUERY_CAPTOR.getValue().toString()).isEqualTo(expectedQueryStructure.toString());
        assertThat(COLLECTION_NAME_CAPTOR.getValue()).isEqualTo(FLATTENED_TEMPLATES_VIEW);
        assertThat(CLASS_TYPE_CAPTOR.getValue()).isEqualTo(FlatTemplateContent.class);
    }

    @Test
    void shouldGetQueryForEmptyJson(){
        JsonObject jsonObject = GSON.fromJson("{}", JsonObject.class);

        String expectedComposedQueryString = "{}";
        Query expectedQuery = new BasicQuery(expectedComposedQueryString);

        helper.getIdsOfDocumentMatchingCriteria(jsonObject);

        verify(mongoTemplate, times(1)).find(QUERY_CAPTOR.capture(), CLASS_TYPE_CAPTOR.capture(), COLLECTION_NAME_CAPTOR.capture());
        Query queryBasedOnCriteria = QUERY_CAPTOR.getValue();

        assertThat(QUERY_CAPTOR.getValue().toString()).isEqualTo(expectedQuery.toString());
        assertThat(COLLECTION_NAME_CAPTOR.getValue()).isEqualTo(FLATTENED_TEMPLATES_VIEW);
        assertThat(CLASS_TYPE_CAPTOR.getValue()).isEqualTo(FlatTemplateContent.class);
    }


    @Test
    void shouldGetQueryWithAllTypeValues(){
        JsonObject jsonObject = GSON.fromJson("{\"stringKey\": \"stringValue\", \"numberKey\": 16.00, \"boolKey\": false}", JsonObject.class);

        helper.getIdsOfDocumentMatchingCriteria(jsonObject);

        verify(mongoTemplate, times(1)).find(QUERY_CAPTOR.capture(), CLASS_TYPE_CAPTOR.capture(), COLLECTION_NAME_CAPTOR.capture());
        Query queryBasedOnCriteria = QUERY_CAPTOR.getValue();

        assertThat(queryBasedOnCriteria.getQueryObject().get("$and")).isInstanceOf(List.class);
        List<Document> conditionDocuments = new ArrayList<>((List<Document>) queryBasedOnCriteria.getQueryObject().get("$and"));
        List<Document> conditions = conditionDocuments.stream().map(el -> (Document) el.get("keyValues")).map(el -> (Document) el.get("$elemMatch")).collect(Collectors.toList());

        assertThat(conditionDocuments).hasSize(3);
        assertJsonPreparedKeyHasCorrectStructure(conditions.get(0), "stringKey");
        assertThat(conditions.get(0).get("v").toString()).isEqualTo(TemplateSearchHelper.getCaseInsensitive("^\\QstringValue\\E$").toString());

        assertJsonPreparedKeyHasCorrectStructure(conditions.get(1), "numberKey");
        assertThat(conditions.get(1).get("v")).isEqualTo(16.0);

        assertJsonPreparedKeyHasCorrectStructure(conditions.get(2), "boolKey");
        assertThat(conditions.get(2).get("v")).isEqualTo("false");
    }

    @Test
    void shouldThrowExceptionWhenNullIsPresentAsCriteriaValue(){
        JsonObject jsonObject = GSON.fromJson("{\"stringKey\": \"stringValue\", \"nullKey\": null}", JsonObject.class);

        assertThrows(IllegalJsonValueException.class, () -> helper.getIdsOfDocumentMatchingCriteria(jsonObject));
    }

    private void assertJsonPreparedKeyHasCorrectStructure(Document actual, String expectedPattern){
        assertThat(actual.get("k").toString()).isEqualTo(Pattern.compile(String.format(":%s(?:(\\[[\\d]+\\]))?$", expectedPattern)).toString());

    }
}
