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

#include "KafkaWrapper.h"
#include <cstdlib>
#include <cinttypes>
#include <iostream>

extern "C" {
    rd_kafka_resp_err_t rd_kafka_last_error (void);
    rd_kafka_resp_err_t rd_kafka_flush (rd_kafka_t *rk, int timeout_ms);
}

extern "C" {
void kafka_delivery_report_callback(rd_kafka_t *rk, const rd_kafka_message_t *rkmessage, void *opaque) {
#ifdef DEBUG
    if (rkmessage->err)
        std::cout<<"%% Message delivery failed: %s\n"<<rd_kafka_err2str(rkmessage->err)<<std::endl;
    else
        std::cout<<
                "%% Message delivered ("<<rkmessage->len <<" bytes, partition " << rkmessage->partition <<")" << std::endl;
    /* The rkmessage is destroyed automatically by librdkafka */
#endif
}
}

KafkaWrapper::KafkaWrapper(const char *brokers, const char *topic_name) {
    this->brokers = brokers;
    this->topic_name = topic_name;

    init();
}

KafkaWrapper::~KafkaWrapper() {
    std::cerr<<"%% Flushing final messages..."<<std::endl;
    rd_kafka_flush(rk, 10 * 1000);
    rd_kafka_destroy(rk);
}

void KafkaWrapper::init() {
    /*Kafka stuff*/
    conf = rd_kafka_conf_new();
    if (rd_kafka_conf_set(conf, "bootstrap.servers", brokers, errstr, sizeof(errstr)) != RD_KAFKA_CONF_OK) {
        perror(errstr);
        exit(1);
    }

    rd_kafka_conf_set_dr_msg_cb(conf, kafka_delivery_report_callback);
    rk = rd_kafka_new(RD_KAFKA_PRODUCER, conf, errstr, sizeof(errstr));
    if (!rk) {
        std::cerr<<"%% Failed to create new producer: %s\n"<<errstr<<std::endl;
        exit(1);
    }

    rkt = rd_kafka_topic_new(rk, topic_name, nullptr);
    if (!rkt) {
        std::cerr<<"%% Failed to create topic object: %s\n"<<
                rd_kafka_err2str(rd_kafka_last_error())<<std::endl;
        rd_kafka_destroy(rk);
        exit(1);
    }
}

void KafkaWrapper::kafka_send_message(std::string message) {
    size_t len = message.length();
    int retry = 1;
    while (retry) {
#ifdef DEBUG
        std::cout<<"Sending the message to topic...\n"<<std::endl;
#endif
        if (rd_kafka_produce(rkt, RD_KAFKA_PARTITION_UA, RD_KAFKA_MSG_F_COPY, (void *) message.c_str(), len, nullptr, 0,
                             nullptr)) {
            retry = 1;
            rd_kafka_resp_err_t last_error = rd_kafka_last_error();
            std::cerr<<"%% Failed to produce to topic %s: %s\n"<<topic_name<<rd_kafka_err2str(last_error)<<std::endl;
            if (last_error == RD_KAFKA_RESP_ERR__QUEUE_FULL) {
                rd_kafka_poll(rk, 1000);
            } else {
                std::cerr<<"%% Enqueued message (%zd bytes) for topic %s\n"<<len<<topic_name<<std::endl;
            }
        } else {
            retry = 0;
        }
    }
    rd_kafka_poll(rk, 0/*non-blocking*/);
}


