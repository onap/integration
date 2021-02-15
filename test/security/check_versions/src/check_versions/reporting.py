#!/usr/bin/env python3

#   Copyright 2020 Orange, Ltd.
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
"""
Generate reult page
"""
import logging
import json
from dataclasses import dataclass
import yaml

from packaging.version import Version

from jinja2 import (  # pylint: disable=import-error
    Environment,
    select_autoescape,
    FileSystemLoader,
)

# Logger
LOG_LEVEL = "INFO"
logging.basicConfig()
LOGGER = logging.getLogger("versions")
LOGGER.setLevel(LOG_LEVEL)

REPORTING_FILE = "/tmp/versions_reporting.html"
RESULT_FILE = "/tmp/versions.json"
RECOMMENDED_VERSIONS_FILE = "/tmp/recommended_versions.yaml"
WAIVER_LIST_FILE = "/tmp/waiver_versions.txt"


@dataclass
class TestResult:
    """Test results retrieved from xtesting."""

    pod_name: str
    container: str
    image: str
    python_version: str
    python_status: int
    java_version: str
    java_status: int


@dataclass
class SerieResult:
    """Serie of tests."""

    serie_id: str
    success_rate: int = 0
    min: int = 0
    max: int = 0
    mean: float = 0.0
    median: float = 0.0
    nb_occurences: int = 0


class OnapVersionsReporting:
    """Build html summary page."""

    def __init__(self, result_file, waiver_file, recommended_versions_file) -> None:
        """Initialization of the report."""
        self._result_file = result_file
        self._waiver_file = waiver_file
        self._recommended_versions_file = recommended_versions_file

    def get_versions_scan_results(self, result_file, waiver_list):
        """Get all the versions from the scan."""
        testresult = []
        # Get the recommended version list for java and python
        min_java_version = self.get_recommended_version(
            RECOMMENDED_VERSIONS_FILE, "java11"
        )
        min_python_version = self.get_recommended_version(
            RECOMMENDED_VERSIONS_FILE, "python3"
        )

        LOGGER.info("Min Java recommended version: %s", min_java_version)
        LOGGER.info("Min Python recommended version: %s", min_python_version)

        with open(result_file) as json_file:
            data = json.load(json_file)
        LOGGER.info("Number of pods: %s", len(data))
        for component in data:
            if component["extra"]["image"] not in waiver_list:
                testresult.append(
                    TestResult(
                        pod_name=component["pod"],
                        container=component["container"],
                        image=component["extra"]["image"],
                        python_version=component["versions"]["python"],
                        java_version=component["versions"]["java"],
                        python_status=self.get_version_status(
                            component["versions"]["python"], min_python_version[0]
                        ),
                        java_status=self.get_version_status(
                            component["versions"]["java"], min_java_version[0]
                        ),
                    )
                )
        LOGGER.info("Nb of pods (after waiver filtering) %s", len(testresult))
        return testresult

    @staticmethod
    def get_version_status(versions, min_version):
        """Based on the min version set the status of the component version."""
        # status_code
        # 0: only recommended version found
        # 1: recommended version found but not alone
        # 2: recommended version not found but not far
        # 3: recommended version not found but not far but not alone
        # 4: recommended version not found
        # we assume that versions are given accordign to usual java way
        # X.Y.Z
        LOGGER.debug("Version = %s", versions)
        LOGGER.debug("Min Version = %s", min_version)
        nb_versions_found = len(versions)
        status_code = -1
        LOGGER.debug("Nb versions found :%s", nb_versions_found)
        # if no version found retrieved -1
        if nb_versions_found > 0:
            for version in versions:
                clean_version = Version(version.replace("_", "."))
                min_version_ok = str(min_version)

                if clean_version >= Version(min_version_ok):
                    if nb_versions_found < 2:
                        status_code = 0
                    else:
                        status_code = 2
                elif clean_version.major >= Version(min_version_ok).major:
                    if nb_versions_found < 2:
                        status_code = 1
                    else:
                        status_code = 3
                else:
                    status_code = 4
        LOGGER.debug("Version status code = %s", status_code)
        return status_code

    @staticmethod
    def get_recommended_version(recommended_versions_file, component):
        """Retrieve data from the json file."""
        with open(recommended_versions_file) as stream:
            data = yaml.safe_load(stream)
            try:
                recommended_version = data[component]["recommended_versions"]
            except KeyError:
                recommended_version = None
        return recommended_version

    @staticmethod
    def get_waiver_list(waiver_file_path):
        """Get the waiver list."""
        pods_to_be_excluded = []
        with open(waiver_file_path) as waiver_list:
            for line in waiver_list:
                line = line.strip("\n")
                line = line.strip("\t")
                if not line.startswith("#"):
                    pods_to_be_excluded.append(line)
        return pods_to_be_excluded

    def generate_reporting(self, result_file):
        """Generate HTML reporting page."""
        LOGGER.info("Generate versions HTML report.")

        # Get the waiver list
        waiver_list = self.get_waiver_list(self._waiver_file)
        LOGGER.info("Waiver list: %s", waiver_list)

        # Get the Versions results
        scan_res = self.get_versions_scan_results(result_file, waiver_list)

        # Create reporting page
        jinja_env = Environment(
            autoescape=select_autoescape(["html"]),
            loader=FileSystemLoader("./templates"),
        )
        page_info = {"title": "ONAP Integration versions reporting"}
        jinja_env.get_template("versions.html.j2").stream(
            info=page_info, data=scan_res
        ).dump("{}".format(REPORTING_FILE))


if __name__ == "__main__":
    test = OnapVersionsReporting(
        RESULT_FILE, WAIVER_LIST_FILE, RECOMMENDED_VERSIONS_FILE
    )
    test.generate_reporting(RESULT_FILE)
