#!/usr/bin/env bash
# This file is part of HDL string format.
#
# Copyright (c) 2015 - 2020 suoto (Andre Souto)
#
# HDL string format is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# HDL string format is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with HDL string format.  If not, see <http://www.gnu.org/licenses/>.

set -e

# Mimic the username, user ID and group ID of the env outside the container to
# avoid permission issues

USERNAME="${USERNAME:-user}"

addgroup "$USERNAME" --gid "$GROUP_ID" > /dev/null 2>&1

adduser --disabled-password            \
  --gid "$GROUP_ID"                    \
  --uid "$USER_ID"                     \
  --home "/home/$USERNAME" "$USERNAME" > /dev/null 2>&1

su -l "$USERNAME" -c "                                                                            \
  pushd /hdl_checker                                                                           && \
  PATH=/builders/msim/modelsim_ase/linuxaloem/:$PATH VUNIT_VHDL_STANDARD=93 ./run.py --clean   && \
  PATH=/builders/msim/modelsim_ase/linuxaloem/:$PATH VUNIT_VHDL_STANDARD=2002 ./run.py --clean && \
  PATH=/builders/msim/modelsim_ase/linuxaloem/:$PATH VUNIT_VHDL_STANDARD=2008 ./run.py --clean && \
  PATH=/builders/ghdl/bin/:$PATH VUNIT_VHDL_STANDARD=93 ./run.py --clean                       && \
  PATH=/builders/ghdl/bin/:$PATH VUNIT_VHDL_STANDARD=2002 ./run.py --clean                     && \
  PATH=/builders/ghdl/bin/:$PATH VUNIT_VHDL_STANDARD=2008 ./run.py --clean"

