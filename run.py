#!/usr/bin/env python
# sformat HDL -- VHDL package to provide C-like string formatting

#
# Copyright 2016 by Andre Souto (suoto)
#
# This file is part of sformat HDL.

# sformat HDL is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# sformat HDL is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with sformat HDL.  If not, see <http://www.gnu.org/licenses/>.
"sformat HDL unit tests"

from os.path import join, dirname
from vunit import VUnit

def main():
    ui = VUnit.from_argv()

    src_path = join(dirname(__file__), "src")

    sformat_hdl = ui.add_library("sformat_hdl")
    sformat_hdl.add_source_files(join(src_path, "*.vhd"))

    sformat_tb = ui.add_library("sformat_tb")
    sformat_tb.add_source_files(join(src_path, "test", "*.vhd"))

    ui.set_compile_option('modelsim.vcom_flags', ['-novopt', '-explicit'])
    ui.set_sim_option('modelsim.vsim_flags', ['-novopt'])
    ui.main()

import sys
sys.exit(main())
