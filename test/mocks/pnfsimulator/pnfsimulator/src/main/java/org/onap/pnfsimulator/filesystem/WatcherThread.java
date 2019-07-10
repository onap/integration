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
import java.nio.file.FileSystems;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardWatchEventKinds;
import java.nio.file.WatchEvent;
import java.nio.file.WatchKey;
import java.nio.file.WatchService;
import lombok.extern.slf4j.Slf4j;
import org.onap.pnfsimulator.db.Storage;
import org.onap.pnfsimulator.template.Template;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Slf4j
@Component
public class WatcherThread implements Runnable {

    private final WatchService watchService;
    private final Storage<Template> storage;
    private final Path templatesDir;

    WatcherThread(String templatesDir, WatchService watchService, Storage<Template> storage) throws IOException {
        this.watchService = watchService;
        this.storage = storage;
        this.templatesDir = Paths.get(templatesDir);
        registerDirectory(this.templatesDir);
    }

    @Autowired
    public WatcherThread(@Value("${templates.dir}") String templatesDir, Storage<Template> storage) throws IOException {
        this(templatesDir, FileSystems.getDefault().newWatchService(), storage);
    }

    private void registerDirectory(Path path) throws IOException {
        path.register(watchService, StandardWatchEventKinds.ENTRY_CREATE, StandardWatchEventKinds.ENTRY_DELETE,
            StandardWatchEventKinds.ENTRY_MODIFY);
    }

    @Override
    public void run() {
        while (true) {
            WatchKey key;
            try {
                key = watchService.take();
                for (WatchEvent<?> event : key.pollEvents()) {
                    WatcherEventProcessor.process(event, storage, templatesDir);
                }
                key.reset();
            } catch (InterruptedException e) {
                log.error("Watch service interrupted.", e.getMessage());
                Thread.currentThread().interrupt();
                return;
            }

        }
    }
}
