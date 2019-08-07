PROJECT = check
BIN_DIR = bin
SRC_DIR = src
PKG_DIR = pkg
BIN = check

all: run

run: build
	$(BIN_DIR)/$(BIN)

build: $(BIN)

$(BIN): export GOPATH = $(shell pwd)
$(BIN): deps
	go install $(PROJECT)/cmd/$(BIN)

deps: export GOPATH = $(shell pwd)
deps:
	go get $(PROJECT)/...

clean_deps: export GOPATH = $(shell pwd)
clean_deps:
	go clean -i -r $(PROJECT)/... 2>/dev/null || true

test: export GOPATH = $(shell pwd)
test: test_deps
	go test $(PROJECT)/...

test_watch: export GOPATH = $(shell pwd)
test_watch: test_deps
	$(BIN_DIR)/ginkgo watch $(SRC_DIR)/$(PROJECT)/...

test_deps: export GOPATH = $(shell pwd)
test_deps:
	go get github.com/onsi/ginkgo/ginkgo
	go get -t $(PROJECT)/...

clean_test_deps: export GOPATH = $(shell pwd)
clean_test_deps:
	go clean -i -r github.com/onsi/ginkgo/ginkgo 2>/dev/null || true

clean: clean_deps clean_test_deps
	-rmdir $(BIN_DIR)
	-rm -rf $(PKG_DIR)
	find $(SRC_DIR) -mindepth 1 -maxdepth 1 ! -name $(PROJECT) -exec rm -rf {} +

.PHONY: all run build deps clean_deps test test_watch test_deps clean_test_deps clean $(BIN)
