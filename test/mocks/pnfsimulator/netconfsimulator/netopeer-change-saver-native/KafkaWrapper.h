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

#ifndef NETOPEER_CHANGE_SAVER_CPP_KAFKAWRAPPER_H
#define NETOPEER_CHANGE_SAVER_CPP_KAFKAWRAPPER_H
#include "librdkafka/rdkafka.h"
#include <string>

class KafkaWrapper {
private:
    char errstr[512];
    const char *brokers;
    const char *topic_name;
    rd_kafka_t *rk;
    rd_kafka_topic_t *rkt;
    rd_kafka_conf_t *conf;

    void init();

public:
    KafkaWrapper(const char *brokers, const char *topic_name);
    ~KafkaWrapper();
    void kafka_send_message(std::string message);
};


#endif //NETOPEER_CHANGE_SAVER_CPP_KAFKAWRAPPER_H
