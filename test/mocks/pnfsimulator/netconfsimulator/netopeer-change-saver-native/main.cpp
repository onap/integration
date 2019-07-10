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

#include <iostream>
#include <csignal>
#include "Application.h"

volatile int exit_application = 0;

void sigterm_handler(int signum) {
    std::cout << "Interrupt signal (" << signum << ") received." << std::endl;
    exit_application = 1;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        std::cerr<<"Usage: "<<argv[0]<<" <module_name> <broker> <topic> "<<std::endl;
        return 1;
    }

    signal(SIGTERM, sigterm_handler);

    const char *module_name = argv[1];
    const char *brokers = argv[2];
    const char *topic_name = argv[3];

    Application application(module_name, brokers, topic_name);
    application.run();

    return 0;
}
