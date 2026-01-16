.PHONY: build clean test lint format package run-all release help set-version update-changelog prepare-release

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

set-version:
	@if [ -z "$(VERSION)" ] || [ -z "$(VERSION_CODE)" ]; then echo "Set VERSION and VERSION_CODE"; exit 1; fi
	@bash build-tools/set-version.sh $(VERSION) $(VERSION_CODE)

update-changelog:
	@if [ -z "$(VERSION)" ] || [ -z "$(NOTES)" ]; then echo "Set VERSION and NOTES (path to notes file)"; exit 1; fi
	@bash build-tools/update-changelog.sh $(VERSION) $(NOTES)

prepare-release:
	@$(MAKE) set-version VERSION=$(VERSION) VERSION_CODE=$(VERSION_CODE)
	@$(MAKE) update-changelog VERSION=$(VERSION) NOTES=$(NOTES)
	@$(MAKE) run-all

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
