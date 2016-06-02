#!/bin/bash

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

# Variables to change by the user, should turn into argument to the script
CASE="GroEL-GroES"
#CASE="RsgA-ribosome"

WDIR=`pwd`

CASEDIR=${CASE}
if [ ${CASE} = "GroEL-GroES" ]
then
  PDBF=GroES_1gru.pdb
  MAPF=1046.map
  RESOL=23.0
fi

if [ ${CASE} = "RsgA-ribosome" ]
then
  PDBF=4adv_V.pdb
  MAPF=2017.map
  RESOL=13.3
fi

ANG="4.71"
PWRFIT_PAR="-a ${ANG} -l"
INPUT_DIR=${WDIR}/${CASEDIR}
PDB=${INPUT_DIR}/${PDBF}
MAP=${INPUT_DIR}/${MAPF}
OUT_DIR="${WDIR}/result"

### Type is "-p NN" options to run on the NN CPUs
TYPE="-p 2"

mkdir -p ${OUT_DIR}
echo "-> Input files: ${PDB} ${MAP} Resolution: ${RESOL}"
echo "-------------------------------------"
echo "-> Executing powerfit ${PDB} ${MAP} ${RESOL} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}"
echo
powerfit ${PDB} ${MAP} ${RESOL} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}
