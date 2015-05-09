#
# Build instructions
#


# Make sure that any failure in a pipe fails the build
SHELL = /bin/bash -o pipefail


# A list of all test names
TESTS ?= $(notdir $(basename $(wildcard test/*_test.nim)))


# Run all tests
.PHONY: test
test: $(TESTS)


# A template for defining targets for a test
define DEFINE_TEST

build/$1: test/$1.nim test/helpers.nim \
		$(shell find -name $(patsubst %_test,%,$1).nim)

	@echo "$1 ... "
	@nimble c \
			--path:. --nimcache:./build/nimcache \
			--out:../build/$1 \
			test/$1.nim \
		| grep -v \
			-e "^Hint: " \
			-e "^CC: " \
			-e "Hint: 'AbortOnError'"
	@build/$1

.PHONY: $1
$1: build/$1

endef

# Define a target for each test
$(foreach test,$(TESTS),$(eval $(call DEFINE_TEST,$(test))))


# Watches for changes and reruns
.PHONY: watch
watch:
	$(eval MAKEFLAGS += " -s ")
	@while true; do \
		make test TESTS="$(TESTS)"; \
		inotifywait -qre close_write `find . -name "*.nim"` > /dev/null; \
		echo "Change detected, re-running..."; \
	done


# Remove all build artifacts
.PHONY: clean
clean:
	rm -rf build

