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
TIME="/usr/bin/time"
TIME_STR="time = %e sec\nMem = %M kB"

# Case PRE5-PUP2-complex
#TYPE is either -g for GPU or -p NN for CPU NN processes
TAG_TYPE="GPU"

INPUT_DIR=${WDIR}/"PRE5-PUP2-complex"
PDB1=${INPUT_DIR}/O14250.pdb
PDB2=${INPUT_DIR}/Q9UT97.pdb
REST=${INPUT_DIR}/restraints.dat

echo "-> Input files: ${PDB1} ${PDB2} ${REST}"

for ANG in "10.0" "5.0"
do
  for VS in "2" "1"
  do
    for i in `seq -w 10`
    do
      TAG="ang-${ANG}-vs-${VS}-type-${TAG_TYPE}-n-${i}"
      TIME_RES="tr_${TAG}.txt"
      OUT_DIR=${WDIR}/"res_${TAG}"
      DISVIS_PAR="-a ${ANG} -vs ${VS}"
      TYPE="-g"
      echo "-------------------------------------"
      echo "-> Params: angle = ${ANG}  voxel spacing = ${VS}"
      echo "-> TYPE = ${TAG_TYPE}"
      echo "-> Run num: ${i}"
      echo
      echo "-> Executing disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
      echo
      echo "${TIME} -f ${TIME_STR} -o ${TIME_RES} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
      #${TIME} -f "${TIME_STR}" -o ${TIME_RES} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}
    done
  done
done


# For CPUs

NCORES=`nproc`
TAG_TYPE="CPU"

for ANG in "10.0" "5.0"
do
  for VS in "2" "1"
  do
    for nc in `seq ${NCORES} -2 1` "1"
    do
      for i in `seq -w 2`
      do
        TAG="ang-${ANG}-vs-${VS}-type-${TAG_TYPE}-ncores-${nc}-n-${i}"
        TIME_RES="tr_${TAG}.txt"
        OUT_DIR=${WDIR}/"res_${TAG}"
        DISVIS_PAR="-a ${ANG} -vs ${VS}"
        TYPE="-p ${nc}"
        echo "-------------------------------------"
        echo "-> Params: angle = ${ANG}  voxel spacing = ${VS}"
        echo "-> TYPE = ${TAG_TYPE}"
        echo "-> Num cores = ${nc}"
        echo "-> Run num: ${i}"
        echo
        echo "-> Executing disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
        echo
        echo "${TIME} -f ${TIME_STR} -o ${TIME_RES} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
        #${TIME} -f "${TIME_STR}" -o ${TIME_RES} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}
      done
    done
  done
done


