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

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

import org.bson.json.JsonParseException;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.filesystem.WatcherEventProcessor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class FsToDbTemplateSynchronizer {

    private static final String CANNOT_SYNC = "Cannot synchronize templates. Check whether the proper folder exists.";
    private static final Logger LOGGER = LoggerFactory.getLogger(FsToDbTemplateSynchronizer.class);

    private final String templatesDir;
    private final Storage<Template> storage;

    @Autowired
    public FsToDbTemplateSynchronizer(@Value("${templates.dir}") String templatesDir,
                                      Storage<Template> storage) {
        this.templatesDir = templatesDir;
        this.storage = storage;
    }

    public void synchronize() {
        try {
            processTemplatesFolder();
        } catch (IOException e) {
            LOGGER.error(CANNOT_SYNC, e);
        }
    }

    private void processTemplatesFolder() throws IOException {
        try (Stream<Path> walk = Files.walk(Paths.get(templatesDir))) {
            walk.filter(Files::isRegularFile).forEach(path -> {
                try {
                    WatcherEventProcessor.MODIFIED.processEvent(path, storage);
                } catch (IOException | JsonParseException e) {
                    LOGGER
                            .error("Cannot synchronize template: " + path.getFileName().toString(), e);
                }
            });
        }
    }
}
