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

package org.onap.pnfsimulator.template.search.viewmodel;


import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.onap.pnfsimulator.db.Row;

import java.util.List;

@Getter
@NoArgsConstructor
@ToString
public class FlatTemplateContent extends Row {

    private List<KeyValuePair> keyValues;


    public FlatTemplateContent(String name, List<KeyValuePair> keyValues) {
        this.id = name;
        this.keyValues = keyValues;
    }
}


