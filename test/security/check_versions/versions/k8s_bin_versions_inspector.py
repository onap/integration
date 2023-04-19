#!/usr/bin/env python3

#   COPYRIGHT NOTICE STARTS HERE
#
#   Copyright 2020 Samsung Electronics Co., Ltd.
#   Copyright 2023 Deutsche Telekom AG
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

"""
k8s_bin_versions_inspector is a module for verifying versions of CPython and
OpenJDK binaries installed in the kubernetes cluster containers.
"""

__title__ = "k8s_bin_versions_inspector"
__summary__ = (
    "Module for verifying versions of CPython and OpenJDK binaries installed"
    " in the kubernetes cluster containers."
)
__version__ = "0.1.0"
__author__ = "kkkk.k@samsung.com"
__license__ = "Apache-2.0"
__copyright__ = "Copyright 2020 Samsung Electronics Co., Ltd."

from typing import Iterable, List, Optional, Pattern, Union

import argparse
import dataclasses
import itertools
import json
import logging
import pathlib
import pprint
import re
import string
import sys
from typing import Iterable, List, Optional, Pattern, Union
import tabulate
import yaml

import kubernetes

RECOMMENDED_VERSIONS_FILE = "/tmp/recommended_versions.yaml"
WAIVER_LIST_FILE = "/tmp/versions_xfail.txt"

# Logger
logging.basicConfig()
LOGGER = logging.getLogger("onap-versions-status-inspector")
LOGGER.setLevel("INFO")


def parse_argv(argv: Optional[List[str]] = None) -> argparse.Namespace:
    """Function for parsing command line arguments.

    Args:
        argv: Unparsed list of command line arguments.

    Returns:
        Namespace with values from parsed arguments.
    """

    epilog = (
        f"Author: {__author__}\n"
        f"License: {__license__}\n"
        f"Copyright: {__copyright__}\n"
    )

    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        prog=__title__,
        description=__summary__,
        epilog=epilog,
        add_help=False,
    )

    parser.add_argument("-c", "--config-file", help="Name of the kube-config file.")

    parser.add_argument(
        "-s",
        "--field-selector",
        default="",
        help="Kubernetes field selector, to filter out containers objects.",
    )

    parser.add_argument(
        "-o",
        "--output-file",
        type=pathlib.Path,
        help="Path to file, where output will be saved.",
    )

    parser.add_argument(
        "-f",
        "--output-format",
        choices=("tabulate", "pprint", "json"),
        default="tabulate",
        help="Format of the output file (tabulate, pprint, json).",
    )

    parser.add_argument(
        "-i",
        "--ignore-empty",
        action="store_true",
        help="Ignore containers without any versions.",
    )

    parser.add_argument(
        "-a",
        "--acceptable",
        type=pathlib.Path,
        help="Path to YAML file, with list of acceptable software versions.",
    )

    parser.add_argument(
        "-n",
        "--namespace",
        help="Namespace to use to list pods."
        "If empty pods are going to be listed from all namespaces",
    )

    parser.add_argument(
        "--check-istio-sidecar",
        action="store_true",
        help="Add if you want to check istio sidecars also",
    )

    parser.add_argument(
        "--istio-sidecar-name",
        default="istio-proxy",
        help="Name of istio sidecar to filter out",
    )

    parser.add_argument(
        "-d",
        "--debug",
        action="store_true",
        help="Enable debugging mode in the k8s API.",
    )

    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="Suppress printing text on standard output.",
    )

    parser.add_argument(
        "-w",
        "--waiver",
        type=pathlib.Path,
        help="Path of the waiver xfail file.",
    )

    parser.add_argument(
        "-V",
        "--version",
        action="version",
        version=f"{__title__} {__version__}",
        help="Display version information and exit.",
    )

    parser.add_argument(
        "-h", "--help", action="help", help="Display this help text and exit."
    )

    args = parser.parse_args(argv)

    return args


@dataclasses.dataclass
class ContainerExtra:
    "Data class, to storage extra informations about container."

    running: bool
    image: str
    identifier: str


@dataclasses.dataclass
class ContainerVersions:
    "Data class, to storage software versions from container."

    python: list
    java: list


@dataclasses.dataclass
class ContainerInfo:
    "Data class, to storage multiple informations about container."

    namespace: str
    pod: str
    container: str
    extra: ContainerExtra
    versions: ContainerVersions = None


def is_container_running(
    status: kubernetes.client.models.v1_container_status.V1ContainerStatus,
) -> bool:
    """Function to determine if k8s cluster container is in running state.

    Args:
        status: Single item from container_statuses list, that represents container status.

    Returns:
        If container is in running state.
    """

    if status.state.terminated:
        return False

    if status.state.waiting:
        return False

    if not status.state.running:
        return False

    return True


def list_all_containers(
    api: kubernetes.client.api.core_v1_api.CoreV1Api,
    field_selector: str,
    namespace: Union[None, str],
    check_istio_sidecars: bool,
    istio_sidecar_name: str,
) -> Iterable[ContainerInfo]:
    """Get list of all containers names.

    Args:
        api: Client of the k8s cluster API.
        field_selector: Kubernetes field selector, to filter out containers objects.
        namespace: Namespace to limit reading pods from
        check_istio_sidecars: Flag to enable/disable istio sidecars check.
            Default to False
        istio_sidecar_name: If checking istio sidecars is disabled the name to filter
            containers out

    Yields:
        Objects for all containers in k8s cluster.
    """

    if namespace:
        pods = api.list_namespaced_pod(namespace, field_selector=field_selector).items
    else:
        pods = api.list_pod_for_all_namespaces(field_selector=field_selector).items

    # Filtering to avoid testing integration or replica pods
    pods = [
        pod
        for pod in pods
        if "replica" not in pod.metadata.name and "integration" not in pod.metadata.name
    ]

    containers_statuses = (
        (pod.metadata.namespace, pod.metadata.name, pod.status.container_statuses)
        for pod in pods
        if pod.status.container_statuses
    )

    containers_status = (
        itertools.product([namespace], [pod], statuses)
        for namespace, pod, statuses in containers_statuses
    )

    containers_chained = itertools.chain.from_iterable(containers_status)

    containers_fields = (
        (
            namespace,
            pod,
            status.name,
            is_container_running(status),
            status.image,
            status.container_id,
        )
        for namespace, pod, status in containers_chained
    )

    container_items = (
        ContainerInfo(
            namespace, pod, container, ContainerExtra(running, image, identifier)
        )
        for namespace, pod, container, running, image, identifier in containers_fields
    )

    if not check_istio_sidecars:
        container_items = filter(
            lambda container: container.container != istio_sidecar_name, container_items
        )

    yield from container_items


def sync_post_namespaced_pod_exec(
    api: kubernetes.client.api.core_v1_api.CoreV1Api,
    container: ContainerInfo,
    command: Union[List[str], str],
) -> dict:
    """Function to execute command on selected container.

    Args:
        api: Client of the k8s cluster API.
        container: Object, that represents container in k8s cluster.
        command: Command to execute as a list of arguments or single string.

    Returns:
        Dictionary that store informations about command execution.
        * stdout - Standard output captured from execution.
        * stderr - Standard error captured from execution.
        * error  - Error object that was received from kubernetes API.
        * code   - Exit code returned by executed process
                   or -1 if container is not running
                   or -2 if other failure occurred.
    """

    stdout = ""
    stderr = ""
    error = {}
    code = -1
    LOGGER.debug("sync_post_namespaced_pod_exec container= %s", container.pod)
    try:
        client_stream = kubernetes.stream.stream(
            api.connect_post_namespaced_pod_exec,
            namespace=container.namespace,
            name=container.pod,
            container=container.container,
            command=command,
            stderr=True,
            stdin=False,
            stdout=True,
            tty=False,
            _request_timeout=1.0,
            _preload_content=False,
        )
        client_stream.run_forever(timeout=5)
        stdout = client_stream.read_stdout()
        stderr = client_stream.read_stderr()
        error = yaml.safe_load(
            client_stream.read_channel(kubernetes.stream.ws_client.ERROR_CHANNEL)
        )

        code = (
            0
            if error["status"] == "Success"
            else -2
            if error["reason"] != "NonZeroExitCode"
            else int(error["details"]["causes"][0]["message"])
        )
    except (
        kubernetes.client.rest.ApiException,
        kubernetes.client.exceptions.ApiException,
    ):
        LOGGER.debug("Discard unexpected k8s client Error..")
    except TypeError:
        LOGGER.debug("Type Error, no error status")
        pass

    return {
        "stdout": stdout,
        "stderr": stderr,
        "error": error,
        "code": code,
    }


def generate_python_binaries() -> List[str]:
    """Function to generate list of names and paths for CPython binaries.

    Returns:
        List of names and paths, to CPython binaries.
    """

    dirnames = ["", "/usr/bin/", "/usr/local/bin/"]

    majors_minors = [
        f"{major}.{minor}" for major, minor in itertools.product("23", string.digits)
    ]

    suffixes = ["", "2", "3"] + majors_minors

    basenames = [f"python{suffix}" for suffix in suffixes]

    binaries = [f"{dir}{base}" for dir, base in itertools.product(dirnames, basenames)]

    return binaries


def generate_java_binaries() -> List[str]:
    """Function to generate list of names and paths for OpenJDK binaries.

    Returns:
        List of names and paths, to OpenJDK binaries.
    """

    binaries = [
        "java",
        "/usr/bin/java",
        "/usr/local/bin/java",
        "/etc/alternatives/java",
        "/usr/java/openjdk-14/bin/java",
    ]

    return binaries


def determine_versions_abstraction(
    api: kubernetes.client.api.core_v1_api.CoreV1Api,
    container: ContainerInfo,
    binaries: List[str],
    extractor: Pattern,
) -> List[str]:
    """Function to determine list of software versions, that are installed in
    given container.

    Args:
        api: Client of the k8s cluster API.
        container: Object, that represents container in k8s cluster.
        binaries: List of names and paths to the abstract software binaries.
        extractor: Pattern to extract the version string from the output of the binary execution.

    Returns:
        List of installed software versions.
    """

    commands = ([binary, "--version"] for binary in binaries)
    commands_old = ([binary, "-version"] for binary in binaries)
    commands_all = itertools.chain(commands, commands_old)

    # TODO: This list comprehension should be parallelized
    results = (
        sync_post_namespaced_pod_exec(api, container, command)
        for command in commands_all
    )

    successes = (
        f"{result['stdout']}{result['stderr']}"
        for result in results
        if result["code"] == 0
    )

    extractions = (extractor.search(success) for success in successes)

    versions = sorted(
        set(extraction.group(1) for extraction in extractions if extraction)
    )

    return versions


def determine_versions_of_python(
    api: kubernetes.client.api.core_v1_api.CoreV1Api, container: ContainerInfo
) -> List[str]:
    """Function to determine list of CPython versions,
    that are installed in given container.

    Args:
        api: Client of the k8s cluster API.
        container: Object, that represents container in k8s cluster.

    Returns:
        List of installed CPython versions.
    """

    extractor = re.compile("Python ([0-9.]+)")

    binaries = generate_python_binaries()

    versions = determine_versions_abstraction(api, container, binaries, extractor)

    return versions


def determine_versions_of_java(
    api: kubernetes.client.api.core_v1_api.CoreV1Api, container: ContainerInfo
) -> List[str]:
    """Function to determine list of OpenJDK versions,
    that are installed in given container.

    Args:
        api: Client of the k8s cluster API.
        container: Object, that represents container in k8s cluster.

    Returns:
        List of installed OpenJDK versions.
    """

    extractor = re.compile('openjdk [version" ]*([0-9._]+)')

    binaries = generate_java_binaries()

    versions = determine_versions_abstraction(api, container, binaries, extractor)

    return versions


def gather_containers_informations(
    api: kubernetes.client.api.core_v1_api.CoreV1Api,
    field_selector: str,
    ignore_empty: bool,
    namespace: Union[None, str],
    check_istio_sidecars: bool,
    istio_sidecar_name: str,
) -> List[ContainerInfo]:
    """Get list of all containers names.

    Args:
        api: Client of the k8s cluster API.
        field_selector: Kubernetes field selector, to filter out containers objects.
        ignore_empty: Determines, if containers with empty versions should be ignored.
        namespace: Namespace to limit reading pods from
        check_istio_sidecars: Flag to enable/disable istio sidecars check.
            Default to False
        istio_sidecar_name: If checking istio sidecars is disabled the name to filter
            containers out

    Returns:
        List of initialized objects for containers in k8s cluster.
    """

    containers = list(
        list_all_containers(
            api, field_selector, namespace, check_istio_sidecars, istio_sidecar_name
        )
    )
    LOGGER.info("List of containers: %s", containers)

    # TODO: This loop should be parallelized
    for container in containers:
        LOGGER.info("Container -----------------> %s", container)
        python_versions = determine_versions_of_python(api, container)
        java_versions = determine_versions_of_java(api, container)
        container.versions = ContainerVersions(python_versions, java_versions)
        LOGGER.info("Container versions: %s", container.versions)

    if ignore_empty:
        containers = [c for c in containers if c.versions.python or c.versions.java]

    return containers


def generate_output_tabulate(containers: Iterable[ContainerInfo]) -> str:
    """Function for generate output string in tabulate format.

    Args:
        containers: List of items, that represents containers in k8s cluster.

     Returns:
         Output string formatted by tabulate module.
    """

    headers = [
        "Namespace",
        "Pod",
        "Container",
        "Running",
        "CPython",
        "OpenJDK",
    ]

    rows = [
        [
            container.namespace,
            container.pod,
            container.container,
            container.extra.running,
            " ".join(container.versions.python),
            " ".join(container.versions.java),
        ]
        for container in containers
    ]

    output = tabulate.tabulate(rows, headers=headers)

    return output


def generate_output_pprint(containers: Iterable[ContainerInfo]) -> str:
    """Function for generate output string in pprint format.

    Args:
        containers: List of items, that represents containers in k8s cluster.

     Returns:
         Output string formatted by pprint module.
    """

    output = pprint.pformat(containers)

    return output


def generate_output_json(containers: Iterable[ContainerInfo]) -> str:
    """Function for generate output string in JSON format.

    Args:
        containers: List of items, that represents containers in k8s cluster.

     Returns:
         Output string formatted by json module.
    """

    data = [
        {
            "namespace": container.namespace,
            "pod": container.pod,
            "container": container.container,
            "extra": {
                "running": container.extra.running,
                "image": container.extra.image,
                "identifier": container.extra.identifier,
            },
            "versions": {
                "python": container.versions.python,
                "java": container.versions.java,
            },
        }
        for container in containers
    ]

    output = json.dumps(data, indent=4)

    return output


def generate_and_handle_output(
    containers: List[ContainerInfo],
    output_format: str,
    output_file: pathlib.Path,
    quiet: bool,
) -> None:
    """Generate and handle the output of the containers software versions.

    Args:
        containers: List of items, that represents containers in k8s cluster.
        output_format: String that will determine output format (tabulate, pprint, json).
        output_file: Path to file, where output will be save.
        quiet: Determines if output should be printed, to stdout.
    """

    output_generators = {
        "tabulate": generate_output_tabulate,
        "pprint": generate_output_pprint,
        "json": generate_output_json,
    }
    LOGGER.debug("output_generators: %s", output_generators)

    output = output_generators[output_format](containers)

    if output_file:
        try:
            output_file.write_text(output)
        except AttributeError:
            LOGGER.error("Not possible to write_text")

    if not quiet:
        LOGGER.info(output)


def verify_versions_acceptability(
    containers: List[ContainerInfo], acceptable: pathlib.Path, quiet: bool
) -> bool:
    """Function for verification of software versions installed in containers.

    Args:
        containers: List of items, that represents containers in k8s cluster.
        acceptable: Path to the YAML file, with the software verification parameters.
        quiet: Determines if output should be printed, to stdout.

    Returns:
        0 if the verification was successful or 1 otherwise.
    """

    if not acceptable:
        return 0

    try:
        acceptable.is_file()
    except AttributeError:
        LOGGER.error("No acceptable file found")
        return -1

    if not acceptable.is_file():
        raise FileNotFoundError(
            "File with configuration for acceptable does not exists!"
        )

    with open(acceptable) as stream:
        data = yaml.safe_load(stream)

    python_acceptable = data.get("python3", [])
    java_acceptable = data.get("java11", [])

    python_not_acceptable = [
        (container, "python3", version)
        for container in containers
        for version in container.versions.python
        if version not in python_acceptable
    ]

    java_not_acceptable = [
        (container, "java11", version)
        for container in containers
        for version in container.versions.java
        if version not in java_acceptable
    ]

    if not python_not_acceptable and not java_not_acceptable:
        return 0

    if quiet:
        return 1

    LOGGER.error("List of not acceptable versions")
    pprint.pprint(python_not_acceptable)
    pprint.pprint(java_not_acceptable)

    return 1


def main(argv: Optional[List[str]] = None) -> str:
    """Main entrypoint of the module for verifying versions of CPython and
    OpenJDK installed in k8s cluster containers.

    Args:
        argv: List of command line arguments.
    """

    args = parse_argv(argv)

    kubernetes.config.load_kube_config(args.config_file)

    api = kubernetes.client.CoreV1Api()
    api.api_client.configuration.debug = args.debug

    containers = gather_containers_informations(
        api,
        args.field_selector,
        args.ignore_empty,
        args.namespace,
        args.check_istio_sidecar,
        args.istio_sidecar_name,
    )

    generate_and_handle_output(
        containers, args.output_format, args.output_file, args.quiet
    )

    code = verify_versions_acceptability(containers, args.acceptable, args.quiet)

    return code


if __name__ == "__main__":
    sys.exit(main())
