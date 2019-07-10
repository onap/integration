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

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Field;

@Builder
@Getter
@Setter
public class EventData {
    @Id
    private String id;

    @Field("template")
    @JsonInclude
    private String template;

    @Field("patched")
    @JsonInclude
    private String patched;

    @Field("input")
    @JsonInclude
    private String input;

    @Field("keywords")
    @JsonInclude
    private String keywords;

    @Field("incrementValue")
    @JsonInclude
    private int incrementValue;

    protected EventData(String id, String template, String patched, String input, String keywords, int incrementValue) {
        this.id = id;
        this.template = template;
        this.patched = patched;
        this.input = input;
        this.keywords = keywords;
        this.incrementValue = incrementValue;
    }

    @Override
    public String toString() {
        return "EventData{"
                + "id='" + id + '\''
                + ", template='" + template + '\''
                + ", patched='" + patched + '\''
                + ", input='" + input + '\''
                + ", keywords='" + keywords + '\''
                + '}';
    }
}
