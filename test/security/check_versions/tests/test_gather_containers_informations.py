#!/usr/bin/env python3

import k8s_bin_versions_inspector as kbvi
import kubernetes


def test_gather_containers_informations(pod_name_trimmer):
    kubernetes.config.load_kube_config()
    api = kubernetes.client.CoreV1Api()
    containers = kbvi.gather_containers_informations(api, "", False)
    data = [
        (
            c.namespace,
            pod_name_trimmer(c.pod),
            c.container,
            c.versions.python,
            c.versions.java,
        )
        for c in containers
    ]
    sorted_data = sorted(data)
    assert sorted_data == [
        ("default", "kbvi-test-java-keycloak", "keycloak", [], ["11.0.8"]),
        ("default", "kbvi-test-java-keycloak-old", "keycloak-old", [], ["11.0.5"]),
        (
            "default",
            "kbvi-test-java-keycloak-very-old",
            "keycloak-very-old",
            ["2.7.5"],
            [],
        ),  # TODO
        ("default", "kbvi-test-python-jupyter", "jupyter", ["3.8.4"], []),
        ("default", "kbvi-test-python-jupyter-old", "jupyter-old", ["3.6.6"], []),
        ("default", "kbvi-test-python-stderr-filebeat", "filebeat", ["2.7.5"], []),
        ("default", "kbvi-test-terminated", "python", [], []),  # TODO
        ("ingress-nginx", "kbvi-test-ingress-nginx", "echo-server", [], []),
        ("kube-system", "kbvi-test-kube-system", "echo-server", [], []),
    ]
