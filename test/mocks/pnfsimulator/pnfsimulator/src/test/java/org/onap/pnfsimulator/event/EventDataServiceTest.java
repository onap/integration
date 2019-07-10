/*
 * ============LICENSE_START=======================================================
 * PNF-REGISTRATION-HANDLER
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

package org.onap.pnfsimulator.event;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.MockitoAnnotations.initMocks;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import org.hamcrest.collection.IsIterableContainingInOrder;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;

public class EventDataServiceTest {

    @Mock
    private EventDataRepository repositoryMock;

    @InjectMocks
    private EventDataService service;

    private static EventData sampleEventData(String id, String template,
                                             String patched, String input, String keywords) {
        return EventData.builder()
                .id(id)
                .template(template)
                .patched(patched)
                .input(input)
                .keywords(keywords)
                .build();
    }

    @BeforeEach
    void resetMocks() {
        initMocks(this);
    }

    @Test
    void persistEventDataJsonObjectTest() {
        JsonParser parser = new JsonParser();
        JsonObject template = parser.parse("{ \"bla1\": \"bla2\"}").getAsJsonObject();
        JsonObject patched = parser.parse("{ \"bla3\": \"bla4\"}").getAsJsonObject();
        JsonObject input = parser.parse("{ \"bla5\": \"bla6\"}").getAsJsonObject();
        JsonObject keywords = parser.parse("{ \"bla7\": \"bla8\"}").getAsJsonObject();
        ArgumentCaptor<EventData> argumentCaptor = ArgumentCaptor.forClass(EventData.class);

        service.persistEventData(template, patched, input, keywords);

        verify(repositoryMock).save(argumentCaptor.capture());
        EventData captured = argumentCaptor.getValue();

        assertEquals(captured.getTemplate(), template.toString());
        assertEquals(captured.getPatched(), patched.toString());
        assertEquals(captured.getInput(), input.toString());
        assertEquals(captured.getKeywords(), keywords.toString());
    }

    @Test
    void getAllEventsTest() {

        List<EventData> eventDataList = new ArrayList<>();
        EventData ed1 = sampleEventData("id1", "t1", "p1", "i1", "k1");
        EventData ed2 = sampleEventData("id2", "t2", "p2", "i2", "k2");
        eventDataList.add(ed1);
        eventDataList.add(ed2);

        when(repositoryMock.findAll()).thenReturn(eventDataList);
        List<EventData> actualList = service.getAllEvents();

        assertEquals(eventDataList.size(), actualList.size());
        assertThat(actualList, IsIterableContainingInOrder.contains(ed1, ed2));
    }

    @Test
    void findByIdPresentTest() {
        String id = "some_object";
        EventData eventData = sampleEventData(id, "template", "patched", "input", "keywords");
        Optional<EventData> optional = Optional.of(eventData);

        when(repositoryMock.findById(id)).thenReturn(optional);

        Optional<EventData> actualOptional = service.getById(id);
        assertTrue(actualOptional.isPresent());
        EventData actualObject = actualOptional.get();
        assertEquals(eventData.getId(), actualObject.getId());
        assertEquals(eventData.getTemplate(), actualObject.getTemplate());
        assertEquals(eventData.getPatched(), actualObject.getPatched());
        assertEquals(eventData.getInput(), actualObject.getInput());
        assertEquals(eventData.getKeywords(), actualObject.getKeywords());

    }

    @Test
    void findByIdNotPresentTest() {
        String id = "some_object";
        Optional<EventData> optional = Optional.empty();

        when(repositoryMock.findById(id)).thenReturn(optional);

        Optional<EventData> actualOptional = service.getById(id);
        assertTrue(!actualOptional.isPresent());
    }
}
