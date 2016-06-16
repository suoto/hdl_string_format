#!/usr/bin/env bash
set -x
VUNIT_VHDL_STANDARD=93 ./run.py --clean
VUNIT_VHDL_STANDARD=2002 ./run.py --clean
VUNIT_VHDL_STANDARD=2008 ./run.py --clean

