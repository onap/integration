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

package org.onap.pnfsimulator.filesystem;

import static junit.framework.TestCase.fail;
import static org.mockito.MockitoAnnotations.initMocks;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchEvent;
import java.time.Instant;
import java.util.Collections;
import java.util.HashMap;
import java.util.Optional;
import org.bson.Document;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.template.Template;

class WatcherEventProcessorTest {

    @Mock
    private WatchEvent watchEvent;
    @Mock
    private Path templatesDir;

    private Storage<Template> storage;
    private static Path jsonFilePath;

    @BeforeAll
    static void init() {
        jsonFilePath = Paths.get("src/test/resources/org/onap/pnfsimulator/simulator/filesystem/test1.json");
    }

    @BeforeEach
    void resetMocks() {
        initMocks(this);
        storage = new InMemoryTemplateStorage();
        initStubs();
    }

    @Test
    void shouldProcessCreatedEventTest() {
        // when
        Mockito.when(watchEvent.kind()).thenReturn(StandardWatchEventKinds.ENTRY_CREATE);
        WatcherEventProcessor.process(watchEvent, storage, templatesDir);
        // then
        verifyPersistedValue();
    }

    @Test
    void shouldProcessModifiedEventTest() {
        //given
        storage.persist(new Template("test1.json", new Document(Collections.emptyMap()), Instant.now().getNano()));
        // when
        Mockito.when(watchEvent.kind()).thenReturn(StandardWatchEventKinds.ENTRY_MODIFY);
        WatcherEventProcessor.process(watchEvent, storage, templatesDir);
        // then
        verifyPersistedValue();
    }

    private void verifyPersistedValue() {
        Assertions.assertEquals(storage.getAll().size(), 1);
        Optional<Template> templateFromStorage = storage.get("test1.json");
        if (templateFromStorage.isPresent()) {
            Template retrievedTemplate = templateFromStorage.get();
            Document templateContent = retrievedTemplate.getContent();
            Document flatContent = retrievedTemplate.getFlatContent();
            Assertions.assertEquals(templateContent.getString("field1"), "value1");
            Assertions.assertEquals(templateContent.getInteger("field2", 0), 2);
            Assertions.assertEquals(flatContent.getInteger(":nested:key1[0]", 0), 1);
            Assertions.assertEquals(flatContent.getInteger(":nested:key1[1]", 0), 2);
            Assertions.assertEquals(flatContent.getInteger(":nested:key1[2]", 0), 3);
            Assertions.assertEquals(flatContent.getString(":nested:key2"), "sampleValue2");
        } else {
            fail();
        }
    }

    @Test
    void shouldProcessDeletedEventTest() {
        //given
        HashMap<String, Object> legacyObject = new HashMap<>();
        legacyObject.put("field1", "value1");
        legacyObject.put("field2", 2);

        storage.persist(new Template("test1.json", new Document(legacyObject), Instant.now().getNano()));
        // when
        Mockito.when(watchEvent.kind()).thenReturn(StandardWatchEventKinds.ENTRY_DELETE);
        WatcherEventProcessor.process(watchEvent, storage, templatesDir);
        // then
        Assertions.assertEquals(storage.getAll().size(), 0);
    }

    private void initStubs() {
        Mockito.when(templatesDir.resolve(jsonFilePath)).thenReturn(jsonFilePath);
        Mockito.when(watchEvent.context()).thenReturn(jsonFilePath);
    }

}
