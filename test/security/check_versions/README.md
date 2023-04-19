# Kubernetes Binaries Versions Inspector

**Kubernetes Binaries Versions Inspector** (`k8s_bin_versions_inspector`) is a
python module for verifying versions of CPython and OpenJDK binaries installed
in the kubernetes cluster containers.

## Commands

### Install dependencies

To install dependencies for normal usage of script, run this command.

```bash
pip3 install -r requirements.txt
```

### Code formatting

```bash
black src tests
```

### Code static analysis

```bash
pylint -d C0330 src
```

### Automatic tests

To running the automated tests is required to have properly configured
kubernetes cluster, which is in the virtual machine, that is containing
development environment.

```bash
PYTHONPATH=src pytest -vv -s tests
```

### Removing caches

```bash
find -name __pycache__   -exec rm -Rf {} +
find -name .pytest_cache -exec rm -Rf {} +
```

## Acceptable format

Example of the acceptable file format:

```yaml
python:
    - 3.6.9
    - 3.7.3
java:
    - 11.0.7
```

## Paths research

Commands to research for the paths
of the software binaries in multiple docker images:

```bash
docker run --entrypoint /bin/sh python:buster   -c "which python"
docker run --entrypoint /bin/sh python:alpine   -c "which python"
docker run --entrypoint /bin/sh python:slim     -c "which python"
docker run --entrypoint /bin/sh python:2-buster -c "which python"
docker run --entrypoint /bin/sh python:2-alpine -c "which python"
docker run --entrypoint /bin/sh python:2-slim   -c "which python"
docker run --entrypoint /bin/sh ubuntu:bionic   -c "apt-get update && apt-get install -y python  && which python"
docker run --entrypoint /bin/sh ubuntu:bionic   -c "apt-get update && apt-get install -y python3 && which python3"
docker run --entrypoint /bin/sh openjdk         -c "type java"
```

## Todo

List of features, that should be implemented:

- Complete license and copyrights variables.
- Find a way, to safe searching of the container files from Kubernetes API.
- Parallelization of executing binaries on the single container.
- Parallelization of versions determination in multiple containers.
- Support for determination the old versions of OpenJDK (attribute `-version`).
- Deleting namespace from cluster in development environment (for example,
  during cluster reset), cause hanging in namespace terminating state.
- Find a nicer way to extracting exit code from execution result.

## Links

- <https://github.com/kubernetes-client/python>
- <https://github.com/kubernetes-client/python/issues/812>
- <https://success.docker.com/article/kubernetes-namespace-stuck-in-terminating>
