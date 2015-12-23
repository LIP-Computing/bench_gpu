#!/bin/bash

#
# bench-disvis.sh: benchmark of disvis run on GPUs
# Execution on physical hosts or VMs
#
# Copyright (C) LIP and IndigoDataCloud EU project
# Author: Mario David <david@lip.pt>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

WDIR=`pwd`
INPUT_DIR=${WDIR}/"PRE5-PUP2-complex"
TIME="/usr/bin/time"
TIME_STR="time = %e sec\n Mem = %M kB"
PDB1=${INPUT_DIR}/O14250.pdb
PDB2=${INPUT_DIR}/Q9UT97.pdb
REST=${INPUT_DIR}/restraints.dat


TIME_RES="tr.txt"
OUT_DIR=${WDIR}/"res"
DISVIS_PAR="-a 9.72 -vs 4"

#TYPE is either -g for GPU or -p NN for CPU NN processes
TYPE="-g"

${TIME} -f "${TIME_STR}" -o ${TIME_RES} \
    disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}


