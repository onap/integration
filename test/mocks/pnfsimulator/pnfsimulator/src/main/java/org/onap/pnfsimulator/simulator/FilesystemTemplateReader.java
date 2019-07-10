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

package org.onap.pnfsimulator.simulator;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Collectors;
import java.util.stream.Stream;

class FilesystemTemplateReader implements TemplateReader {

    private final Path templatesDir;
    private final Gson gson;

    @Autowired
    FilesystemTemplateReader(@Value("${templates.dir}") String templatesDir, Gson gson) {
        this.templatesDir = Paths.get(templatesDir);
        this.gson = gson;
    }

    public JsonObject readTemplate(String templateFileName) throws IOException {
        Path absTemplateFilePath = templatesDir.resolve(templateFileName);
        try (Stream<String> lines = Files.lines(absTemplateFilePath)) {
            String content = lines.collect(Collectors.joining("\n"));
            return gson.fromJson(content, JsonObject.class);
        }
    }
}

