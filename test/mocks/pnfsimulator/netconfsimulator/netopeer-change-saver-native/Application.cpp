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

#include "Application.h"
#include <cstdio>
#include <unistd.h>
#include "sysrepo/Session.hpp"
#include "SysrepoCallback.h"

Application::~Application() {
    this->subscriber->unsubscribe();
    this->session->session_stop();
    sr_disconnect(this->connection->_conn);
    std::cout << "Application closed correctly " << std::endl;
}

void Application::run() {
    /*create kafka wrapper object*/
    KafkaWrapper kafkaWrapper(this->brokers, this->topic_name);

    std::cout << "Application will watch for changes in " << module_name << std::endl;
    /* connect to sysrepo */
    this->connection = new sysrepo::Connection("example_application");
    sysrepo::S_Connection conn(new sysrepo::Connection("example_application"));

    /* start session */
    sysrepo::S_Session sess(new sysrepo::Session(conn));

    this->session = sess;
    /* subscribe for changes in running config */
    sysrepo::S_Subscribe subscribe(new sysrepo::Subscribe(sess));
    std::shared_ptr<SysrepoCallback> cb(new SysrepoCallback(kafkaWrapper));

    subscribe->module_change_subscribe(module_name, cb);
    this->subscriber = subscribe;
    
    /* read startup config */
    std::cout << "\n ========== READING STARTUP CONFIG: ==========\n" << std::endl;

    cb->print_current_config(sess, module_name);

    std::cout << "\n ========== STARTUP CONFIG APPLIED AS RUNNING ==========\n" << std::endl;

    /* loop until ctrl-c is pressed / SIGINT is received */
    while (!exit_application) {
        sleep(1000);  /* or do some more useful work... */
    }

    std::cout << "Application exit requested, exiting." << std::endl;

}

Application::Application(const char *module_name, const char *brokers, const char *topic_name) {
    this->module_name = module_name;
    this->brokers = brokers;
    this->topic_name = topic_name;
}
