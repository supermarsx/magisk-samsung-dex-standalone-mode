.PHONY: build clean test

build:
	bash build-tools/build-create-module.sh

clean:
	bash build-tools/build-delete-module.sh

test:
	bash tests/run-tests.sh
