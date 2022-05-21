# Copyright 2015-2022 The libcount Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. See the AUTHORS file for names of
# contributors.

# Uncomment exactly one of the lines labelled (A), (B), and (C) below
# to switch between compilation modes.

# A: Production use (full optimizations)
#OPT ?= -O3 -DNDEBUG

# B: Debug mode, with full line-level debugging symbols
OPT ?= -g2

# C: Profiling mode: optimizations, but w/debugging symbols
#OPT ?= -O3 -g2 -DNDEBUG

PREFIX ?= /usr/local

# Warning Flags
WARNINGFLAGS = -Wall -Werror

# Detect what platform we're building on
$(shell CXX="$(CXX)" TARGET_OS="$(TARGET_OS)" \
	./build_config build_config.mk .)

# Include the file generated by the previous line to set build flags, sources
include build_config.mk

AR = ar
RANLIB = ranlib
CXXFLAGS += -I. -I./include $(PLATFORM_CXXFLAGS) $(OPT) $(WARNINGFLAGS)
COUNT_OBJECTS = $(COUNT_FILES:.cc=.o)
TESTS = empirical_data_test

# Targets
all: libcount.a

.PHONY:
tests: $(TESTS)
	for t in $(TESTS); do echo "** Running $$t"; ./$$t || exit 1; done

.PHONY:
clean:
	-rm -f */*.o build_config.mk *.a c_example cc_example merge_example $(TESTS)

c_example: examples/c_example.o libcount.a
	$(CXX) $(CXXFLAGS) examples/c_example.o libcount.a -o $@ -lcrypto

cc_example: examples/cc_example.o libcount.a
	$(CXX) $(CXXFLAGS) examples/cc_example.o libcount.a -o $@ -lcrypto

check: examples/check.o libcount.a
	$(CXX) $(CXXFLAGS) examples/check.o libcount.a -o $@ -lcrypto
	./check

empirical_data_test: count/empirical_data_test.o libcount.a
	$(CXX) $(CXXFLAGS) count/empirical_data_test.o libcount.a -o $@

merge_example: examples/merge_example.o libcount.a
	$(CXX) $(CXXFLAGS) examples/merge_example.o libcount.a -o $@ -lcrypto

.PHONY:
examples: c_example cc_example merge_example

.PHONY: install
install: libcount.a
	cp libcount.a "$(PREFIX)/lib"
	mkdir -p "$(PREFIX)/include/count"
	cp include/count/*.h "$(PREFIX)/include/count"

libcount.a: $(COUNT_OBJECTS)
	$(AR) rcs libcount.a $(COUNT_OBJECTS)
	$(RANLIB) libcount.a

.PHONY:
linecount:
	wc -l $(CPPLINT_SOURCES)

.PHONY:
lint:
	$(LINT_TOOL) $(CPPLINT_SOURCES)

.PHONY:
neat: clean
	-rm -f *~ .*~ */*~ ./include/*/*~

.PHONY:
reformat:
	clang-format -i $(CPPLINT_SOURCES)

# Suffix Rules
.c.o:
	$(CC) $(CXXFLAGS) -c $< -o $@

.cc.o:
	$(CXX) $(CXXFLAGS) -c $< -o $@

