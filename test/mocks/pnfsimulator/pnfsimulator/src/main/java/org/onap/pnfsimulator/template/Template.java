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

import java.util.Objects;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.onap.pnfsimulator.db.Row;
import org.bson.Document;
import org.onap.pnfsimulator.template.search.JsonUtils;
import org.springframework.data.mongodb.core.mapping.Field;

@NoArgsConstructor
@ToString
public class Template extends Row {

    @Field("content")
    private Document content;

    @Field("flatContent")
    private Document flatContent;

    @Field("lmod")
    private long lmod;

    public Template(String name, Document content, long lmod) {
        this.id = name;
        this.content = content;
        this.lmod = lmod;
        this.flatContent = new JsonUtils().flatten(content);
    }

    public Template(String name, String template, long lmod) {
        this.id = name;
        this.content = Document.parse(template);
        this.lmod = lmod;
        this.flatContent = new JsonUtils().flatten(this.content);
    }

    public void setContent(Document content) {
        this.content = content;
        this.flatContent = new JsonUtils().flatten(content);
    }

    public Document getContent() {
        return new Document(this.content);
    }

    @JsonIgnore
    public Document getFlatContent() {
        return new Document(this.flatContent);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        Template template = (Template) o;
        return Objects.equals(content, template.content)
                && Objects.equals(id, template.id)
                && Objects.equals(lmod, template.lmod);
    }

    @Override
    public int hashCode() {
        return Objects.hash(content, id);
    }
}
