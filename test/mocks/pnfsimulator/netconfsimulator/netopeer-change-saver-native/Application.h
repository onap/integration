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

#ifndef NETOPEER_CHANGE_SAVER_CPP_APPLICATION_H
#define NETOPEER_CHANGE_SAVER_CPP_APPLICATION_H
#include "sysrepo/Sysrepo.hpp"

extern volatile int exit_application;

class Application {
private:
    const char *module_name;
    const char *brokers;
    const char *topic_name;
    sysrepo::S_Session session;
    sysrepo::S_Subscribe subscriber;
    sysrepo::Connection *connection;

public:
    Application(const char *module_name, const char *brokers, const char *topic_name);
    ~Application();
    void run();

};

#endif //NETOPEER_CHANGE_SAVER_CPP_APPLICATION_H
