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

FROM suoto/hdl_checker_test:latest

RUN pip3 install vunit-hdl

ENV PACKAGES="libx11-6:i386 \
              libxrender1:i386 \
              libxtst6:i386 \
              libxi6:i386 \
              libxft2:i386"


RUN apt-get update -qq            && \
    apt-get install -qq $PACKAGES && \
    apt-get clean                 && \
    rm -rf /var/lib/apt/lists/*

ENV BUILDERS /builders
RUN "$BUILDERS/msim/modelsim_ase/linuxaloem/vsim" -version
