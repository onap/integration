PROJECT = check
BIN_DIR = bin
BIN = check

all: run

run: build
	$(BIN_DIR)/$(BIN)

build: $(BIN)

$(BIN): export GOPATH = $(shell pwd)
$(BIN):
	go install $(PROJECT)/cmd/$(BIN)

clean:
	rm $(BIN_DIR)/$(BIN)
	rmdir $(BIN_DIR)

.PHONY: all run build clean $(BIN)
