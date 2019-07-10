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

#ifndef NETOPEER_CHANGE_SAVER_CPP_SYSREPOCALLBACK_H
#define NETOPEER_CHANGE_SAVER_CPP_SYSREPOCALLBACK_H
#include "KafkaWrapper.h"
#include "sysrepo/Session.hpp"
#include <memory>

class SysrepoCallback: public sysrepo::Callback {
private:
    std::shared_ptr<KafkaWrapper> kafkaWrapper;

public:
    explicit SysrepoCallback(std::shared_ptr<KafkaWrapper> wrapper);
    void print_current_config(sysrepo::S_Session session, const char *module_name);

private:
    std::string create_message(sysrepo::S_Change change);
    int module_change(sysrepo::S_Session sess, const char *module_name, sr_notif_event_t event, void *private_ctx);

};


#endif //NETOPEER_CHANGE_SAVER_CPP_SYSREPOCALLBACK_H
