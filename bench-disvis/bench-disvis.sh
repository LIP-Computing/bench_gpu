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

# Variables to change by the user, should turn into argument to the script
#CASE="PRE5-PUP2-complex"
CASE="RNA-polymerase-II"

# Number of runs of each type for statistical purposes
NRUNS=4

#############################################################
# From here on everyhting is fixed
WDIR=`pwd`
TIME="/usr/bin/time"
TIME_STR="time = %e sec\nMem = %M kB"

#TYPE is either -g for GPU or -p NN for CPU NN processes
TAG_TYPE="GPU"

if [ ${CASE} = "PRE5-PUP2-complex" ]
then
  PDBF1=O14250.pdb
  PDBF2=Q9UT97.pdb
  CASEDIR=${CASE}
fi

if [ ${CASE} = "RNA-polymerase-II" ]
then
  PDBF1=1wcm_A.pdb
  PDBF2=1wcm_E.pdb
  CASEDIR=${CASE}/A-E
fi

INPUT_DIR=${WDIR}/${CASEDIR}
PDB1=${INPUT_DIR}/${PDBF1}
PDB2=${INPUT_DIR}/${PDBF1}
REST=${INPUT_DIR}/restraints.dat
RESOUT=${WDIR}/res-${CASE}
TIMEOUT=${WDIR}/time-${CASE}

mkdir -p ${RESOUT}
mkdir -p ${TIMEOUT}

echo "-> Input files: ${PDB1} ${PDB2} ${REST}"

for ANG in "10.0" "5.0"
do
  for VS in "2" "1"
  do
    for i in `seq -w ${NRUNS}`
    do
      TAG="ang-${ANG}-vs-${VS}-type-${TAG_TYPE}-n-${i}"
      TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
      OUT_DIR=${RESOUT}/"res_${TAG}"
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
      for i in `seq -w ${NRUNS}`
      do
        TAG="ang-${ANG}-vs-${VS}-type-${TAG_TYPE}-ncores-${nc}-n-${i}"
        TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
        OUT_DIR=${RESOUT}/"res_${TAG}"
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


