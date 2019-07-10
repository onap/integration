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

#include "SysrepoCallback.h"
#define CREATED "CREATED"
#define DELETED "DELETED"
#define MODIFIED "MODIFIED"
#define MOVED "MOVED"
#define XPATH_MAX_LEN 100


int SysrepoCallback::module_change(sysrepo::S_Session sess, const char *module_name, sr_notif_event_t event, void *private_ctx) {
    {
        if (event == SR_EV_APPLY) {
            char change_path[XPATH_MAX_LEN];

            try {
#ifdef DEBUG
                std::cout << "\n ========== CHANGES: =============================================\n" << std::endl;
#endif
                snprintf(change_path, XPATH_MAX_LEN, "/%s:*", module_name);
                auto it = sess->get_changes_iter(&change_path[0]);
                while (auto change = sess->get_change_next(it)) {
                    std::string message = create_message(change);
                    std::cout<<message<<std::endl;
                    kafkaWrapper->kafka_send_message(message);
                }
#ifdef DEBUG
                std::cout << "\n ========== END OF CHANGES =======================================\n" << std::endl;
#endif
            } catch( const std::exception& e ) {
                std::cerr << e.what() << std::endl;
            }
        }
        return SR_ERR_OK;
    }
}

SysrepoCallback::SysrepoCallback(std::shared_ptr<KafkaWrapper> wrapper) {
    this->kafkaWrapper = wrapper;
}

std::string SysrepoCallback::create_message(sysrepo::S_Change change) {
    std::string change_details;
    sysrepo::S_Val new_val = change->new_val();
    sysrepo::S_Val old_val = change->old_val();

    switch (change->oper()) {
        case SR_OP_CREATED:
            if (nullptr != new_val) {
                change_details.append(CREATED).append(": ").append(new_val->to_string());
            }
            break;
        case SR_OP_DELETED:
            if (nullptr != old_val) {
                change_details.append(DELETED).append(": ").append(old_val->to_string());
            }
            break;
        case SR_OP_MODIFIED:
            if (nullptr != old_val && nullptr != new_val) {
                change_details.append(MODIFIED).append(": ").append(": old value: ").append(old_val->to_string())
                .append(", new value: ").append(new_val->to_string());
            }
            break;
        case SR_OP_MOVED:
            if (nullptr != old_val && nullptr != new_val) {
                change_details.append(MOVED).append(": ").append(new_val->to_string())
                        .append(" after ").append(old_val->to_string());
            } else if (nullptr != new_val) {
                change_details.append(MOVED).append(": ").append(new_val->xpath()).append(" last");
            }
            break;
    }
    return change_details;
}

void SysrepoCallback::print_current_config(sysrepo::S_Session session, const char *module_name) {
    char select_xpath[XPATH_MAX_LEN];
    try {
        snprintf(select_xpath, XPATH_MAX_LEN, "/%s:*//*", module_name);

        auto values = session->get_items(&select_xpath[0]);
        if (values == nullptr)
            return;

        for(unsigned int i = 0; i < values->val_cnt(); i++)
            std::cout << values->val(i)->to_string();
    } catch( const std::exception& e ) {
        std::cout << e.what() << std::endl;
    }
}
