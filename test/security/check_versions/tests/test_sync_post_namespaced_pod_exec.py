#!/usr/bin/env python3

import k8s_bin_versions_inspector as kbvi
import kubernetes


def exec_sync_post_namespaced_pod_exec(pod, command):
    kubernetes.config.load_kube_config()
    api = kubernetes.client.CoreV1Api()
    containers = kbvi.list_all_containers(api, "")
    container = next(c for c in containers if c.pod.startswith(pod))
    result = kbvi.sync_post_namespaced_pod_exec(api, container, command)
    return result


def test_sync_post_namespaced_pod_exec():
    pod = "kbvi-test-python-jupyter"
    result = exec_sync_post_namespaced_pod_exec(pod, "id")
    assert result == {
        "stdout": "uid=1000(jovyan) gid=100(users) groups=100(users)\n",
        "stderr": "",
        "error": {"status": "Success", "metadata": {}},
        "code": 0,
    }


def test_sync_post_namespaced_pod_exec_not_running():
    pod = "kbvi-test-terminated"
    result = exec_sync_post_namespaced_pod_exec(pod, "id")
    assert result == {"stdout": "", "stderr": "", "error": {}, "code": -1}


def test_sync_post_namespaced_pod_exec_not_found():
    pod = "kbvi-test-python-jupyter"
    command = "/command/not/found"
    result = exec_sync_post_namespaced_pod_exec(pod, command)
    assert result["stdout"] == ""
    assert result["stderr"] == ""
    assert result["error"]["status"] == "Failure"
    assert result["error"]["reason"] == "InternalError"
    assert result["code"] == -2


def test_sync_post_namespaced_pod_exec_exit_code():
    pod = "kbvi-test-python-jupyter"
    command = ["python3", "--invalid-attribute"]
    result = exec_sync_post_namespaced_pod_exec(pod, command)
    assert result == {
        "stdout": "",
        "stderr": "unknown option --invalid-attribute\n"
        "usage: python3 [option] ... [-c cmd | -m mod | file | -] [arg] ...\n"
        "Try `python -h' for more information.\n",
        "error": {
            "status": "Failure",
            "reason": "NonZeroExitCode",
            "message": "command terminated with non-zero exit code: error "
            "executing command [python3 --invalid-attribute], exit code 2",
            "details": {"causes": [{"message": "2", "reason": "ExitCode"}]},
            "metadata": {},
        },
        "code": 2,
    }


def test_sync_post_namespaced_pod_exec_stderr():
    pod = "kbvi-test-python-stderr-filebeat"
    command = ["python", "--version"]
    result = exec_sync_post_namespaced_pod_exec(pod, command)
    assert result == {
        "stdout": "",
        "stderr": "Python 2.7.5\n",
        "error": {"status": "Success", "metadata": {}},
        "code": 0,
    }
