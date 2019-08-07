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
test:
	go test $(PROJECT)/...

clean: clean_deps
	-rmdir $(BIN_DIR)
	rm -rf $(PKG_DIR)
	find $(SRC_DIR) -mindepth 1 -maxdepth 1 ! -name $(PROJECT) -exec rm -rf {} +

.PHONY: all run build deps clean_deps test clean $(BIN)
