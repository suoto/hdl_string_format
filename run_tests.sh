#!/usr/bin/env bash
# This file is part of HDL string format.
#
# Copyright (c) 2015 - 2019 suoto (Andre Souto)
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

set -xe

PATH_TO_THIS_SCRIPT=$(readlink -f "$(dirname "$0")")

docker run                                                            \
  --rm                                                                \
  --mount type=bind,source="$PATH_TO_THIS_SCRIPT",target=/hdl_checker \
  --env USER_ID="$(id -u)"                                            \
  --env GROUP_ID="$(id -g)"                                           \
  --env USERNAME="$USER"                                              \
  suoto/hdl_string_format:latest /bin/bash -c '.ci/docker_entry_point.sh'
