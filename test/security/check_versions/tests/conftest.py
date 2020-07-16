#!/usr/bin/env python3

import pytest


def pod_name_trimmer_fun(pod_name):
    return "-".join(pod_name.split("-")[:-2])


@pytest.fixture
def pod_name_trimmer():
    return pod_name_trimmer_fun
