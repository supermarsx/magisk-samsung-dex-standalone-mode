.PHONY: build clean test lint

build:
	bash build-tools/build-create-module.sh

clean:
	bash build-tools/build-delete-module.sh

test:
	bash tests/run-tests.sh

lint:
	shellcheck $(git ls-files '*.sh')
