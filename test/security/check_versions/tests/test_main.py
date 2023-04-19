#!/usr/bin/env python3

import k8s_bin_versions_inspector as kbvi
import json
import tempfile
import yaml


def exec_main(pod_name_trimmer, acceptable_data):
    with tempfile.NamedTemporaryFile() as output_temp, tempfile.NamedTemporaryFile() as acceptable_temp:
        with open(acceptable_temp.name, "w") as stream:
            yaml.safe_dump(acceptable_data, stream)

        result = kbvi.main(
            [
                "--quiet",
                "--output-file",
                output_temp.name,
                "--output-format",
                "json",
                "--acceptable",
                acceptable_temp.name,
            ]
        )

        with open(output_temp.name, "r") as stream:
            output_data = json.load(stream)
            output_extracted = (
                (
                    item["namespace"],
                    pod_name_trimmer(item["pod"]),
                    item["container"],
                    item["versions"]["python"],
                    item["versions"]["java"],
                )
                for item in output_data
            )
            output_sorted = sorted(output_extracted)

    assert output_sorted == [
        ("default", "kbvi-test-java-keycloak", "keycloak", [], ["11.0.8"]),
        ("default", "kbvi-test-java-keycloak-old", "keycloak-old", [], ["11.0.5"]),
        (
            "default",
            "kbvi-test-java-keycloak-very-old",
            "keycloak-very-old",
            ["2.7.5"],
            [],
        ),
        ("default", "kbvi-test-python-jupyter", "jupyter", ["3.8.4"], []),
        ("default", "kbvi-test-python-jupyter-old", "jupyter-old", ["3.6.6"], []),
        ("default", "kbvi-test-python-stderr-filebeat", "filebeat", ["2.7.5"], []),
        ("default", "kbvi-test-terminated", "python", [], []),
        ("ingress-nginx", "kbvi-test-ingress-nginx", "echo-server", [], []),
        ("kube-system", "kbvi-test-kube-system", "echo-server", [], []),
    ]

    return result


def test_main(pod_name_trimmer):
    acceptable_data = {
        "python": ["2.7.5", "3.6.6", "3.8.4"],
        "java": ["11.0.5", "11.0.8"],
    }

    result = exec_main(pod_name_trimmer, acceptable_data)

    assert result == 0


def test_main_neg(pod_name_trimmer):
    acceptable_data = {
        "python": ["3.6.6", "3.8.4"],
        "java": ["11.0.5", "11.0.8"],
    }

    result = exec_main(pod_name_trimmer, acceptable_data)

    assert result == 1
