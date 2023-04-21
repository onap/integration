#!/usr/bin/env python3

#   COPYRIGHT NOTICE STARTS HERE
#
#   Copyright 2020 Samsung Electronics Co., Ltd.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   COPYRIGHT NOTICE ENDS HERE

import logging
import pathlib
import time
import os
import wget
from kubernetes import client, config
from xtesting.core import testcase  # pylint: disable=import-error

import versions.reporting as Reporting
from versions.k8s_bin_versions_inspector import (
    gather_containers_informations,
    generate_and_handle_output,
    verify_versions_acceptability,
)

RECOMMENDED_VERSIONS_FILE = "/tmp/recommended_versions.yaml"
WAIVER_LIST_FILE = "/tmp/versions_xfail.txt"

# Logger
logging.basicConfig()
LOGGER = logging.getLogger("onap-versions-status-inspector")
LOGGER.setLevel("INFO")


class Inspector(testcase.TestCase):
    """Inspector CLass."""

    def __init__(self, **kwargs):
        """Init the testcase."""
        if "case_name" not in kwargs:
            kwargs["case_name"] = "check_versions"
        super().__init__(**kwargs)

        version = os.getenv("ONAP_VERSION", "master")
        base_url = "https://git.onap.org/integration/seccom/plain"

        self.namespace = "onap"
        # if no Recommended file found, download it
        if pathlib.Path(RECOMMENDED_VERSIONS_FILE).is_file():
            self.acceptable = pathlib.Path(RECOMMENDED_VERSIONS_FILE)
        else:
            self.acceptable = wget.download(
                base_url + "/recommended_versions.yaml?h=" + version,
                out=RECOMMENDED_VERSIONS_FILE,
            )
        self.output_file = "/tmp/versions.json"
        # if no waiver file found, download it
        if pathlib.Path(WAIVER_LIST_FILE).is_file():
            self.waiver = pathlib.Path(WAIVER_LIST_FILE)
        else:
            self.waiver = wget.download(
                base_url + "/waivers/versions/versions_xfail.txt?h=" + version,
                out=WAIVER_LIST_FILE,
            )
        self.result = 0
        self.start_time = None
        self.stop_time = None

    def run(self):
        """Execute the version Inspector."""
        self.start_time = time.time()
        config.load_kube_config()
        api = client.CoreV1Api()

        field_selector = "metadata.namespace==onap"

        containers = gather_containers_informations(api, field_selector, True, None, False, "istio-proxy")
        LOGGER.info("gather_containers_informations")
        LOGGER.info(containers)
        LOGGER.info("---------------------------------")

        generate_and_handle_output(
            containers, "json", pathlib.Path(self.output_file), True
        )
        LOGGER.info("generate_and_handle_output in %s", self.output_file)
        LOGGER.info("---------------------------------")

        code = verify_versions_acceptability(containers, self.acceptable, True)
        LOGGER.info("verify_versions_acceptability")
        LOGGER.info(code)
        LOGGER.info("---------------------------------")

        # Generate reporting
        test = Reporting.OnapVersionsReporting(result_file=self.output_file)
        LOGGER.info("Prepare reporting")
        self.result = test.generate_reporting(self.output_file)
        LOGGER.info("Reporting generated")

        self.stop_time = time.time()
        if self.result >= 90:
            return testcase.TestCase.EX_OK
        return testcase.TestCase.EX_TESTCASE_FAILED

    def set_namespace(self, namespace):
        """Set namespace."""
        self.namespace = namespace
