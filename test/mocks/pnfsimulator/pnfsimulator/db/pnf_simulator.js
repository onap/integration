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

const res = [
  db.createUser({ user: 'pnf_simulator_user', pwd: 'zXcVbN123!', roles: ['readWrite', 'dbAdmin'] }),
  db.simulatorConfig.insert({"vesServerUrl": "http://xdcae-ves-collector.onap:8080/eventListener/v7"}),
  db.createCollection("template"),
  db.createView("flatTemplatesView", "template", [{"$project":{"keyValues":{"$objectToArray": "$$ROOT.flatContent"}}}])
];

printjson(res);
