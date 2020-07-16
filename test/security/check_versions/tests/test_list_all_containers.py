#!/usr/bin/env python3

import k8s_bin_versions_inspector as kbvi
import kubernetes


def exec_list_all_containers(pod_name_trimmer, field_selector):
    kubernetes.config.load_kube_config()
    api = kubernetes.client.CoreV1Api()
    containers = kbvi.list_all_containers(api, field_selector)
    extracted = ((c.namespace, c.pod, c.container) for c in containers)
    trimmed = ((n, pod_name_trimmer(p), c) for n, p, c in extracted)
    result = sorted(trimmed)
    return result


def test_list_all_containers(pod_name_trimmer):
    result = exec_list_all_containers(pod_name_trimmer, "")
    assert result == [
        ("default", "kbvi-test-java-keycloak", "keycloak"),
        ("default", "kbvi-test-java-keycloak-old", "keycloak-old"),
        ("default", "kbvi-test-java-keycloak-very-old", "keycloak-very-old"),
        ("default", "kbvi-test-python-jupyter", "jupyter"),
        ("default", "kbvi-test-python-jupyter-old", "jupyter-old"),
        ("default", "kbvi-test-python-stderr-filebeat", "filebeat"),
        ("default", "kbvi-test-terminated", "python"),
        ("ingress-nginx", "kbvi-test-ingress-nginx", "echo-server"),
        ("kube-system", "kbvi-test-kube-system", "echo-server"),
    ]


def test_list_all_containers_not_default(pod_name_trimmer):
    field_selector = "metadata.namespace!=default"
    result = exec_list_all_containers(pod_name_trimmer, field_selector)
    assert result == [
        ("ingress-nginx", "kbvi-test-ingress-nginx", "echo-server"),
        ("kube-system", "kbvi-test-kube-system", "echo-server"),
    ]


def test_list_all_containers_conjunction(pod_name_trimmer):
    field_selector = "metadata.namespace!=kube-system,metadata.namespace!=ingress-nginx"
    result = exec_list_all_containers(pod_name_trimmer, field_selector)
    assert result == [
        ("default", "kbvi-test-java-keycloak", "keycloak"),
        ("default", "kbvi-test-java-keycloak-old", "keycloak-old"),
        ("default", "kbvi-test-java-keycloak-very-old", "keycloak-very-old"),
        ("default", "kbvi-test-python-jupyter", "jupyter"),
        ("default", "kbvi-test-python-jupyter-old", "jupyter-old"),
        ("default", "kbvi-test-python-stderr-filebeat", "filebeat"),
        ("default", "kbvi-test-terminated", "python"),
    ]
