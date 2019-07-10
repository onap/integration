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

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchEvent;
import java.nio.file.WatchEvent.Kind;
import java.time.Instant;
import java.util.Arrays;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import lombok.extern.slf4j.Slf4j;
import org.bson.json.JsonParseException;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.template.Template;
import org.bson.Document;

@Slf4j
public enum WatcherEventProcessor {
    CREATED(StandardWatchEventKinds.ENTRY_CREATE) {
        @Override
        public void processEvent(Path path, Storage<Template> storage) throws IOException {
            String content = getContent(path);
            String fileName = path.getFileName().toString();
            Document documentsContent = Document.parse(content);
            storage.persist(new Template(fileName, documentsContent, Instant.now().getNano()));
            log.info("DB record created for template: " + fileName);
        }
    },
    MODIFIED(StandardWatchEventKinds.ENTRY_MODIFY) {
        @Override
        public void processEvent(Path path, Storage<Template> storage) throws IOException {
            String fileName = path.getFileName().toString();
            String content = getContent(path);
            Document documentsContent = Document.parse(content);
            Template template = storage.get(fileName).orElse(new Template(fileName, documentsContent, Instant.now().getNano()));
            template.setContent(documentsContent);
            storage.persist(template);
            log.info("DB record modified for template: " + fileName);
        }
    },
    DELETED(StandardWatchEventKinds.ENTRY_DELETE) {
        @Override
        public void processEvent(Path path, Storage<Template> storage) {
            String fileName = path.getFileName().toString();
            storage.delete(fileName);
            log.info("DB record deleted for template: " + fileName);
        }
    };

    private final Kind<Path> pathKind;

    String getContent(Path path) throws IOException {
        try (Stream<String> lines = Files.lines(path, StandardCharsets.UTF_8)) {
            return lines.collect(Collectors.joining(System.lineSeparator()));
        } catch (IOException e) {
            log.error("Could not get content due to: " + e.getMessage() + " " + e.getCause(), e);
            throw e;
        }
    }

    WatcherEventProcessor(Kind<Path> pathKind) {
        this.pathKind = pathKind;
    }

    public abstract void processEvent(Path templateName, Storage<Template> storage) throws IOException;

    static void process(WatchEvent<?> event, Storage<Template> storage, Path templatesDir) {
        Optional<WatcherEventProcessor> watcherEventProcessor = getWatcherEventProcessor(event);
        watcherEventProcessor.ifPresent(processor -> {
            try {
                final Path templatePath = templatesDir.resolve((Path) event.context());
                processor.processEvent(templatePath, storage);
            } catch (IOException e) {
                log.error("Error during processing DB record for template.", e);
            } catch (JsonParseException e) {
                log.error("Invalid JSON format provided for template.", e);
            }
        });
    }

    private static Optional<WatcherEventProcessor> getWatcherEventProcessor(WatchEvent<?> event) {
        return Arrays.stream(values()).filter(value -> value.pathKind.equals(event.kind())).findFirst();
    }

}
