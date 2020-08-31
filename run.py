#!/usr/bin/env python3
# hdl_string_format -- VHDL package to provide C-like string formatting

#
# Copyright 2016 by Andre Souto (suoto)
#
# This file is part of hdl_string_format.

# hdl_string_format is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# hdl_string_format is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with hdl_string_format.  If not, see <http://www.gnu.org/licenses/>.
"hdl_string_format unit tests"

from os.path import join, dirname
from vunit import VUnit

def main():
    ui = VUnit.from_argv()
    ui.enable_location_preprocessing()

    src_path = join(dirname(__file__), "src")

    str_format = ui.add_library("str_format")
    str_format.add_source_files(join(src_path, "*.vhd"))

    str_format_tb = ui.add_library("str_format_tb")
    str_format_tb.add_source_files(join(src_path, "test", "*.vhd"))

    ui.set_compile_option('modelsim.vcom_flags', ['-novopt', '-explicit'])
    ui.set_sim_option('modelsim.vsim_flags', ['-novopt'])
    ui.main()

import sys
sys.exit(main())
