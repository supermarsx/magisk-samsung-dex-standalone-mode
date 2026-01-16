.PHONY: build clean test lint format package run-all release help

SHELL := /usr/bin/env bash

lint:
	@bash build-tools/lint.sh

format:
	@bash build-tools/format.sh

test:
	@bash build-tools/test.sh

package build:
	@bash build-tools/package.sh

run-all:
	@bash build-tools/run-all.sh

release:
	@bash build-tools/release.sh

clean:
	@bash build-tools/build-delete-module.sh

help:
	@echo "Available targets:"
	@echo "  lint     - Run shellcheck on all .sh files"
	@echo "  format   - Run shfmt in diff mode"
	@echo "  test     - Run version check and test suite"
	@echo "  package  - Build the ZIP module"
	@echo "  run-all  - Lint, format, test, and package"
	@echo "  release  - Full release: lint/format/test/package, commit, tag, upload"
	@echo "  clean    - Delete generated ZIP"
