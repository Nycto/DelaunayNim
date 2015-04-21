#
# Build instructions
#


# A list of all test names
TESTS ?= $(notdir $(basename $(wildcard test/*_test.nim)))


# Run all tests
.PHONY: test
test: $(TESTS)


# A template for defining targets for a test
define DEFINE_TEST
.PHONY: $1
$1:
	@echo "$1 ... "
	$$(shell mkdir -p build/tmp)
	$$(eval LOG := $$(shell mktemp --tmpdir=build/tmp --suffix=.$1))
	@nim c \
		--path:. --nimcache:../build/nimcache \
		--out:../build/$1 \
		test/$1.nim 2>&1 > $$(LOG) || (cat $$(LOG) && exit 1);
	@build/$1
	@rm $$(LOG)
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

