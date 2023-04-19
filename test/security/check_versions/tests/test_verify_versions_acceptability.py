#!/usr/bin/env python3

import k8s_bin_versions_inspector as kbvi
import yaml
import tempfile
import pathlib


def exec_verify_versions_acceptability(containers):
    config = {
        "python": ["1.1.1", "2.2.2"],
        "java": ["3.3.3"],
    }

    with tempfile.NamedTemporaryFile() as temp:
        with open(temp.name, "w") as stream:
            yaml.safe_dump(config, stream)
        acceptable = pathlib.Path(temp.name)
        result = kbvi.verify_versions_acceptability(containers, acceptable, True)

    return result


def test_verify_versions_acceptability():
    containers = [
        kbvi.ContainerInfo("a", "b", "c", None, kbvi.ContainerVersions([], [])),
        kbvi.ContainerInfo(
            "a", "b", "c", None, kbvi.ContainerVersions(["1.1.1"], ["3.3.3"])
        ),
    ]

    result = exec_verify_versions_acceptability(containers)

    assert result == 0


def test_verify_versions_acceptability_neg_1():
    containers = [
        kbvi.ContainerInfo("a", "b", "c", None, kbvi.ContainerVersions(["3.3.3"], []))
    ]

    result = exec_verify_versions_acceptability(containers)

    assert result == 1


def test_verify_versions_acceptability_neg_2():
    containers = [
        kbvi.ContainerInfo("a", "b", "c", None, kbvi.ContainerVersions([], ["1.1.1"]))
    ]

    result = exec_verify_versions_acceptability(containers)

    assert result == 1
