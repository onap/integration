BUILD_DIR = bin
BUILD_DOCKER_IMAGE = sslendpoints-build-img
BUILD_DOCKER_CONTAINER = sslendpoints-build
BINARIES = sslendpoints
BINARIES := $(addprefix ${BUILD_DIR}/, ${BINARIES})

.PHONY: all
all: docker-build

.PHONY: clean
clean: clean-docker-build clean-build

.PHONY: test
test:
	go test ./...

.PHONY: docker-build
docker-build: ${BINARIES}
	docker rm "${BUILD_DOCKER_CONTAINER}"

${BINARIES}: docker-container | ${BUILD_DIR}
	docker cp "${BUILD_DOCKER_CONTAINER}:/$@" $@

.PHONY: docker-container
docker-container: docker-build-img
	docker create --name "${BUILD_DOCKER_CONTAINER}" "${BUILD_DOCKER_IMAGE}"

.PHONY: docker-build-img
docker-build-img:
	docker build --tag "${BUILD_DOCKER_IMAGE}" .

${BUILD_DIR}:
	mkdir -p "${BUILD_DIR}"

.PHONY: clean-docker-build
clean-docker-build:
	-docker rm "${BUILD_DOCKER_CONTAINER}"
	-docker rmi "${BUILD_DOCKER_IMAGE}"

.PHONY: clean-build
clean-build:
	-rm -f ${BINARIES}
	-rmdir ${BUILD_DIR}
