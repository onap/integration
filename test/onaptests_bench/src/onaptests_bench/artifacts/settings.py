"""Specific settings module."""

# ============LICENSE_START=======================================================
#  Copyright (C) 2022 Orange, Ltd.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

######################
#                    #
# ONAP INPUTS DATAS  #
#                    #
######################

# Variables to set logger information
# Possible values for logging levels in onapsdk: INFO, DEBUG , WARNING, ERROR
LOG_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "default": {
            "class": "logging.Formatter",
            "format": "%(asctime)s %(levelname)s %(lineno)d:%(filename)s(%(process)d) - %(message)s"
        }
    },
    "handlers": {
        "console": {
            "level": "WARN",
            "class": "logging.StreamHandler",
            "formatter": "default"
        },
        "file": {
            "level": "DEBUG",
            "class": "logging.FileHandler",
            "formatter": "default",
            "filename": "/var/lib/xtesting/results/pythonsdk.debug.log",
            "mode": "w"
        }
    },
    "root": {
        "level": "INFO",
        "handlers": ["console", "file"]
    }
}
CLEANUP_FLAG = False
SDC_CLEANUP = False

# SOCK_HTTP = "socks5h://127.0.0.1:8080"
REPORTING_FILE_PATH = "/var/lib/xtesting/results/reporting.html"
K8S_REGION_TYPE = "k8s"
TILLER_HOST = "localhost"
K8S_CONFIG = None  # None means it will use default config (~/.kube/config)
K8S_NAMESPACE = "onap"  # Kubernetes namespace
ORCHESTRATION_REQUEST_TIMEOUT = 60.0 * 30  # 30 minutes in seconds

AAI_URL         = "https://aai-api.simpledemo.onap.org"
CDS_URL         = "https://cds-blueprintsprocessor-api.simpledemo.onap.org"
K8SPLUGIN_URL   = "https://multicloud-k8s-api.simpledemo.onap.org"
MSB_URL         = "https://msb-iag-ui.simpledemo.onap.org"
SDC_BE_URL      = "https://sdc-be-api.simpledemo.onap.org"
SDC_FE_URL      = "https://sdc-fe-ui.simpledemo.onap.org"
SDNC_URL        = "https://sdnc-api.simpledemo.onap.org"
SO_URL          = "https://so-api.simpledemo.onap.org"
CLAMP_URL       = "https://policy-ui.simpledemo.onap.org"
VES_URL         = "https://dcae-ves-collector-api.simpledemo.onap.org"
DMAAP_URL       = "https://dmaap-mr-api.simpledemo.onap.org"
NBI_URL         = "https://nbi-api.simpledemo.onap.org"
HOLMES_URL      = "https://holmes-rule-mgmt-ui.simpledemo.onap.org"
AAI_GUI_URL     = "https://aai-sparkybe-api.simpledemo.onap.org"
