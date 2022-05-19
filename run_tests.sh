#!/bin/bash
# TODO(growly): Write a Makefile.

IVERILOG_BIN=iverilog
TEST_BIN=lut_test

SRC_FILES="src/lut.v src/base_lut.v src/predecoder.v"
TEST_SRC=tests/lut_test.v

${IVERILOG_BIN} -o "${TEST_BIN}" "${DEFINES}" ${SRC_FILES} ${TEST_SRC} && ./"${TEST_BIN}"

# Fracturable
DEFINES="-DFRACTURABLE" 
${IVERILOG_BIN} -o "${TEST_BIN}" ${DEFINES} ${SRC_FILES} ${TEST_SRC} && ./"${TEST_BIN}"

# Pre-decoded
DEFINES="-DFRACTURABLE -DPREDECODE_2" 
${IVERILOG_BIN} -o "${TEST_BIN}" ${DEFINES} ${SRC_FILES} ${TEST_SRC} && ./"${TEST_BIN}"
