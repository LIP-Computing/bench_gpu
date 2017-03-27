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

# Number of runs of each type for statistical purposes
NRUNS=20
# This is for physical machines or VMs
MACH=Phys-C7-QK5200
#MACH=VM-U16-TK40

ROOT_DIR=/cloud/root

ROOT_INPUT_DIR=${ROOT_DIR}/bench-input
OUT_DIR=${ROOT_DIR}/bench-run5
R_OUT_DIR=${OUT_DIR}/results
T_OUT_DIR=${OUT_DIR}/time

#############################################################
# From here on everyhting is fixed
TIME="/usr/bin/time"
TIME_STR="%e"

#TYPE is either -g for GPU or -p NN for CPU NN processes
TAG_TYPE="GPU"

for CASE in "PRE5-PUP2-complex" "RNA-polymerase-II"
do
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

    INPUT_DIR=${ROOT_INPUT_DIR}/${CASEDIR}
    PDB1=${INPUT_DIR}/${PDBF1}
    PDB2=${INPUT_DIR}/${PDBF2}
    REST=${INPUT_DIR}/restraints.dat
    RESOUT=${R_OUT_DIR}/res-${CASE}
    TIMEOUT=${T_OUT_DIR}/${MACH}/time-${CASE}
    mkdir -p ${RESOUT}
    mkdir -p ${TIMEOUT}
    echo "-> Input files: ${PDB1} ${PDB2} ${REST}"

    for i in `seq -w ${NRUNS}`
    do
      for ANG in "10.0" "5.0"
      do
        for VS in "2" "1"
        do
          if [ ${CASE} = "RNA-polymerase-II" ] && [ ${ANG} = "5.0" ] && [ ${VS} = "1" ]
          then
            continue
          fi
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
          echo "-> Executing:"
          echo     "${TIME} -f ${TIME_STR} -o ${TIME_RES} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
          echo
          ${TIME} -f "${TIME_STR}" -o ${TIME_RES} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}
        done
      done
    done
done

for CASE in "GroEL-GroES" "RsgA-ribosome"
do
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

    INPUT_DIR=${ROOT_INPUT_DIR}/${CASEDIR}
    PDB=${INPUT_DIR}/${PDBF}
    MAP=${INPUT_DIR}/${MAPF}
    RESOUT=${R_OUT_DIR}/res-${CASE}
    TIMEOUT=${T_OUT_DIR}/${MACH}/time-${CASE}

    mkdir -p ${RESOUT}
    mkdir -p ${TIMEOUT}

    echo "-> Input files: ${PDB} ${MAP} Resolution: ${RESOL}"

    for i in `seq -w ${NRUNS}`
    do
      TAG="ang-${ANG}-type-${TAG_TYPE}-n-${i}"
      TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
      OUT_DIR=${RESOUT}/"res_${TAG}"
      TYPE="-g"
      echo "-------------------------------------"
      echo "-> Params: angle = ${ANG} -l = Use the Laplace pre-filter density data"
      echo "-> TYPE = ${TAG_TYPE}"
      echo "-> Run num: ${i}"
      echo
      echo "-> Executing:"
      echo     "${TIME} -f ${TIME_STR} -o ${TIME_RES} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}"
      echo
      ${TIME} -f "${TIME_STR}" -o ${TIME_RES} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}
    done

done

CASE="gromacs"
INPUT_DIR=${ROOT_INPUT_DIR}/${CASE}
RESOUT=${R_OUT_DIR}/res-${CASE}
TIMEOUT=${T_OUT_DIR}/${MACH}/time-${CASE}
INFILE=${INPUT_DIR}/md.tpr
. /usr/local/gromacs/bin/GMXRC.bash

for i in `seq -w ${NRUNS}`
do
  TAG="n-${i}"
  TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
  OUT_DIR=${RESOUT}/"res_${TAG}"
  echo "-------------------------------------"
  echo "-> Run num: ${i}"
  echo
  echo "-> Executing:"
  echo     "${TIME} -f "${TIME_STR}" -o ${TIME_RES} gmx mdrun -s ${INFILE} -ntomp 0 -gpu_id 0"
  echo
  mkdir -p ${OUT_DIR}
  cd ${OUT_DIR}
  ${TIME} -f "${TIME_STR}" -o ${TIME_RES} gmx mdrun -s ${INFILE} -ntomp 0 -gpu_id 0
done

