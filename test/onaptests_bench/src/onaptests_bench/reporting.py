#!/usr/bin/env python3

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
"""
Aggregate test results
"""
import logging
import os
import re

from dataclasses import dataclass
from datetime import datetime
import matplotlib.pyplot as plt # pylint: disable=import-error

from jinja2 import Environment, select_autoescape, PackageLoader # pylint: disable=import-error

# Logger
LOG_LEVEL = 'INFO'
logging.basicConfig()
LOGGER = logging.getLogger("onaptests_bench")
LOGGER.setLevel(LOG_LEVEL)

RESULT_DIR_PATH = "/tmp/mytest"
RESULT_LOG_FILE = "xtesting.log"
RESULT_LOG_REPORTING_FILE = "reporting.html"
FIGURE_NAME = "mygraph.png"
USE_CASE_NAME = "unknwown"  # could be checked with result parsing
TIMEOUT_RUN = 1200 # parameter to be provided by the launcher
TEST_DURATION = 120 # parameter to be provided by the launcher
NB_SIMULTANEOUS_TESTS = 10 # parameter to be provided by the launcher
REPORTING_DIR = "/tmp/"

@dataclass
class TestResult:
    """Test results retrieved from xtesting."""
    case_name: str
    status: str = "FAIL"
    start_date: datetime = "2000-01-01 00:00:01,123"
    duration: int = 0

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

class OnaptestBenchReporting:
    """Build html summary page."""

    def __init__(self, nb_simultaneous_tests=NB_SIMULTANEOUS_TESTS,
                 duration=TEST_DURATION,
                 res_dir_path=RESULT_DIR_PATH,
                 reporting_dir=REPORTING_DIR) -> None:
        """Initialization of the report."""
        self._case_name = USE_CASE_NAME
        self._nb_simultaneous_tests = nb_simultaneous_tests
        self._test_duration = duration
        self._result_dir_path = res_dir_path
        self._reporting_dir = reporting_dir

    def parse_xtesting_results(self, file_result):
        """Retrieve data from a xtesting file."""
        # we need to retrieve:
        # (- the name)
        # - the start date
        # - the status
        # - the duration
        # note Data could be in DB but let's aggreage based on the log to avoid
        # dependency to the DB
        # 2021-01-22 07:01:58,467 - xtesting.ci.run_tests - INFO - Test result:
        #
        # +------------------------+---------------------+------------------+----------------+
        # |     TEST CASE          |       PROJECT       |     DURATION     |     RESULT     |
        # +------------------------+---------------------+------------------+----------------+
        # |      basic_onboard     |     integration     |      19:53       |      PASS      |
        # +------------------------+---------------------+------------------+----------------+
        #
        # 2021-01-22 07:01:58 - xtesting.ci.run_tests - INFO - Execution exit value: Result.EX_OK
        start_date = ""
        case_name = ""
        duration = TIMEOUT_RUN
        status = 0
        with open(file_result) as xtesting_result:
            for cnt, line in enumerate(xtesting_result):
                LOGGER.debug(cnt)

                if "Running test case" in line:
                    start_date = line.split()[0] + " " + line.split()[1]
                    self._case_name = (re.search('\'(.*)\'', line)).group(1)

                # if test ends properly, overwrite start tile with end time
                # for a better display
                if "Execution exit value" in line:
                    start_date = line.split()[0] + " " + line.split()[1]

                # Look for the result table
                if "|" in line and self._case_name in line:
                    duration_str = line.split()[5]
                    duration = int(
                        duration_str.split(":")[0])*60 + int(
                            duration_str.split(":")[1])
                    if line.split()[7] == "PASS":
                        status = 100
                    else:
                        status = 0

        testresult = TestResult(
            case_name=case_name,
            status=status,
            start_date=datetime.strptime(start_date, '%Y-%m-%d %H:%M:%S,%f'),
            duration=duration)
        return testresult

    @staticmethod
    def calculate_stats(durations):
        """From a duration results, retrieve the min, max, mean & median value."""

        min_val = min(durations)
        max_val = max(durations)

        # Mean
        total = sum(durations)
        length = len(durations)
        for nums in [durations]:
            LOGGER.debug(nums)
            mean_val = total / length

        # Median
        lst = sorted(durations)
        med_val = sorted(lst)
        lst_len = len(lst)
        index = (lst_len - 1) // 2
        median_val = 0
        if lst_len % 2:
            median_val = med_val[index]
        else:
            median_val = (med_val[index] + med_val[index + 1])/2.0

        return min_val, max_val, mean_val, median_val

    @staticmethod
    def calculate_success_rate(criterias):
        """Calculate Serie success rate."""
        # calculate success rate
        score = 0
        for criteria in criterias:
            score += criteria
        try:
            rate = score/len(criterias)
        except ZeroDivisionError:
            rate = 0
        return rate


    def parse_serie_durations(self): # pylint: disable=too-many-locals
        """Find result series."""
        # from the res directory find all the subdirectory and build an array of results
        series = []
        serie_names = []
        serie_durations = {}
        serie_criteria = {}

        for root, dirs, files in os.walk(self._result_dir_path):
            try:
                dirs.sort(key=lambda x: int(x.split("/")[-1][5:]))
            except ValueError:
                LOGGER.debug("sort only what is sortable")

            LOGGER.debug("Root: %s, Dirs: %s, Files: %s", root, dirs, files)

            for name in files:
                if name == RESULT_LOG_FILE:
                    serie_name = root.split("/")[-2]
                    # if new serie detected, initialize it
                    if serie_name not in serie_names:
                        serie_names.append(serie_name)
                        serie_durations[serie_name] = []
                        serie_criteria[serie_name] = []
                    serie_raw_results = self.parse_xtesting_results(
                        root + "/" + RESULT_LOG_FILE)
                    serie_durations[serie_name].append(
                        serie_raw_results.duration)
                    serie_criteria[serie_name].append(
                        serie_raw_results.status)
        for serie in serie_names:
            LOGGER.info("Calculate stats and success rate of serie %s", serie)
            LOGGER.debug(serie_durations[serie])
            LOGGER.debug(serie_criteria[serie])
            # calculate stats
            min_val, max_val, mean_val, med_val = self.calculate_stats(
                serie_durations[serie])
            success_rate = self.calculate_success_rate(
                serie_criteria[serie])
            series.append(SerieResult(
                serie_id=serie,
                min=min_val,
                max=max_val,
                mean=mean_val,
                median=med_val,
                success_rate=success_rate,
                nb_occurences=len(serie_durations[serie])))

        return series

    def create_duration_time_serie(self):
        """Create Histogram and scattered figure."""
        # duration,success = f(time)
        x_array_pass = []
        x_array_fail = []
        y_array_pass = []
        y_array_fail = []
        for root, dirs, files in os.walk(self._result_dir_path):
            LOGGER.debug("Root: %s, Dirs: %s, Files: %s", root, dirs, files)
            for name in files:
                if name == RESULT_LOG_FILE:
                    serie_raw_results = self.parse_xtesting_results(
                        root + "/" + RESULT_LOG_FILE)
                    LOGGER.debug("Date %s", serie_raw_results.start_date)
                    LOGGER.debug("Status %s", serie_raw_results.status)
                    LOGGER.debug("Duration %s", serie_raw_results.duration)
                    # x_array.append(serie_raw_results.start_date)
                    if serie_raw_results.status < 100:
                        y_array_fail.append(serie_raw_results.duration)
                        x_array_fail.append(serie_raw_results.start_date)
                    else:
                        y_array_pass.append(serie_raw_results.duration)
                        x_array_pass.append(serie_raw_results.start_date)
        plt.scatter(x_array_pass, y_array_pass, color='blue', label='PASS')
        plt.scatter(x_array_fail, y_array_fail, color='red', label='FAIL')
        plt.xlabel("time")
        plt.ylabel("Duration of the test (s)")
        plt.legend()
        plt.savefig(self._reporting_dir + FIGURE_NAME)
        plt.close()

        # Create Histogramme
        plt.hist(y_array_pass)
        plt.xlabel("Duration of the test")
        plt.ylabel("Number of tests")
        plt.savefig(self._reporting_dir + "histo_" + FIGURE_NAME)
        plt.close()

    def create_success_rate(self, series_bench):
        """Draw success rate = f(serie ID)"""
        # Create a vizualisation of success rate
        # success_rate = f(time)
        x_array_success_rate = []
        y_array_success_rate = []

        for serie in series_bench:
            x_array_success_rate.append(serie.serie_id)
            y_array_success_rate.append(int(serie.success_rate))
        LOGGER.info(" Success rate vector: %s", y_array_success_rate)
        plt.bar(range(len(y_array_success_rate)),
                y_array_success_rate,
                width=0.5,
                color='blue')
        # plt.plot(x_array_success_rate, y_array_success_rate, '-o', color='orange')
        plt.xlabel("Series")
        plt.ylabel("Success rate (%)")
        plt.savefig(self._reporting_dir + "bar_" + FIGURE_NAME)
        plt.close()

    def create_cumulated_success_rate(self, series_bench):
        """Draw success rate = f(nb executed tests)"""
        # Create success_rate=f(nb test executed)
        x_array_cumulated_success_rate = []
        y_array_cumulated_success_rate = []
        nb_test = 0
        nb_success_test = 0
        for serie in series_bench:
            # calculate the number of tests
            nb_test += self._nb_simultaneous_tests
            # recalculate success rate
            nb_success_test += int(serie.success_rate)*self._nb_simultaneous_tests
            success_rate = nb_success_test / nb_test
            x_array_cumulated_success_rate.append(nb_test)
            y_array_cumulated_success_rate.append(success_rate)
        plt.plot(
            x_array_cumulated_success_rate,
            y_array_cumulated_success_rate,
            '-o', color='blue')
        plt.xlabel("Nb of executed tests")
        plt.ylabel("Success rate (%)")
        plt.savefig(self._reporting_dir + "rate_" + FIGURE_NAME)
        plt.close()


    def generate_reporting(self):
        """Generate Serie reporting."""
        series_bench = self.parse_serie_durations()
        LOGGER.info(series_bench)

        # create html page
        jinja_env = Environment(
            autoescape=select_autoescape(['html']),
            loader=PackageLoader('onaptests_bench'))

        page_info = {}
        page_info['usecase_name'] = self._case_name
        page_info['nb_series'] = str(len(series_bench))
        page_info['nb_simu_tests'] = str(self._nb_simultaneous_tests)
        page_info['test_duration'] = self._test_duration
        page_info['nb_tests'] = self._nb_simultaneous_tests * len(series_bench)
        success_rate_vector = []
        min_durations = []
        max_durations = []
        mean_durations = []

        for serie in series_bench:
            success_rate_vector.append(int(serie.success_rate))
            min_durations.append(int(serie.min))
            max_durations.append(int(serie.max))
            mean_durations.append(int(serie.mean))

        page_info['global_success_rate'] = int(self.calculate_success_rate(
            success_rate_vector))
        page_info['min_duration'] = min(min_durations)
        page_info['max_duration'] = max(max_durations)
        page_info['mean_duration'] = int(
            self.calculate_success_rate(mean_durations))
        jinja_env.get_template(
            'onaptests_bench.html.j2').stream(
                info=page_info,
                data=series_bench).dump(
                    '{}/onaptests_bench.html'.format(self._reporting_dir))

        self.create_duration_time_serie()
        self.create_success_rate(series_bench)
        self.create_cumulated_success_rate(series_bench)
