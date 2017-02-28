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
NRUNS=10
LWDIR="/cloud/root/bench-run4"

# Run docker or udocker
EXEC="docker"
#EXEC="udocker.py"

####### This is for containers Centos7
MACH=Dock-C7-QK5200
#MACH=Dock-C7-TK40

#MACH=UDock-C7-QK5200
#MACH=UDock-C7-TK40

# Docker container name
DOCK_NAME=haddock-centos7-build2

###############################
####### This is for containers Ubuntu16.04
#MACH=Dock-U16-QK5200
#MACH=Dock-U16-TK40

#MACH=UDock-U16-QK5200
#MACH=UDock-U16-TK40

# Docker container name
#DOCK_NAME=haddock-ubuntu16.04-build2

#############################################################
# From here on everyhting is fixed
WDIR='/home'  # Working dir inside the docker
TIME="/usr/bin/time"
TIME_STR="%e\ntime = %e sec"
DOCK_NVD="--device=/dev/nvidia0:/dev/nvidia0 \
          --device=/dev/nvidiactl:/dev/nvidiactl \
          --device=/dev/nvidia-uvm:/dev/nvidia-uvm"
VDIR="-v ${LWDIR}:${WDIR}"

DOCK_OPT="${VDIR}"

if [ ${EXEC} = "docker" ]
then
  DOCK_OPT="${DOCK_NVD} ${VDIR}"
fi

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

    INPUT_DIR=${WDIR}/${CASEDIR}
    PDB1=${INPUT_DIR}/${PDBF1}
    PDB2=${INPUT_DIR}/${PDBF2}
    REST=${INPUT_DIR}/restraints.dat
    RESOUT=${WDIR}/${MACH}/res-${CASE}
    LRESOUT=${LWDIR}/${MACH}/res-${CASE}
    TIMEOUT=${LWDIR}/${MACH}/time-${CASE}
    mkdir -p ${LRESOUT}
    mkdir -p ${TIMEOUT}
    echo "-> Input files: ${PDB1} ${PDB2} ${REST}"
    DOCK_RUN="${EXEC} run ${DOCK_OPT} ${DOCK_NAME}"

    for i in `seq -w ${NRUNS}`
    do
      for ANG in "10.0" "5.0"
      do
        for VS in "2" "1"
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
          echo "-> Executing:"
          echo     "${TIME} -f ${TIME_STR} -o ${TIME_RES} ${DOCK_RUN} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
          echo
          ${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} disvis ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}

          if [ ${EXEC} = "docker" ]
          then
            docker rm `docker ps -aq`
          fi

          if [ ${EXEC} = "udocker.py" ]
          then
            udocker.py rm `udocker.py ps|cut -d" " -f 1|grep -v CONTAINER`
          fi
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
    INPUT_DIR=${WDIR}/${CASEDIR}
    PDB=${INPUT_DIR}/${PDBF}
    MAP=${INPUT_DIR}/${MAPF}
    RESOUT=${WDIR}/${MACH}/res-${CASE}
    LRESOUT=${LWDIR}/${MACH}/res-${CASE}
    TIMEOUT=${LWDIR}/${MACH}/time-${CASE}
    mkdir -p ${LRESOUT}
    mkdir -p ${TIMEOUT}
    echo "-> Input files: ${PDB} ${MAP} Resolution: ${RESOL}"
    DOCK_RUN="${EXEC} run ${DOCK_OPT} ${DOCK_NAME}"

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
      echo     "${TIME} -f ${TIME_STR} -o ${TIME_RES} ${DOCK_RUN} powerfit ${PDB1} ${PDB2} ${REST} ${DISVIS_PAR} ${TYPE} -d ${OUT_DIR}"
      echo
      ${TIME} -f "${TIME_STR}" -o ${TIME_RES} ${DOCK_RUN} powerfit ${MAP} ${RESOL} ${PDB} ${PWRFIT_PAR} ${TYPE} -d ${OUT_DIR}

      if [ ${EXEC} = "docker" ]
      then
        docker rm `docker ps -aq`
      fi

      if [ ${EXEC} = "udocker.py" ]
      then
        udocker.py rm `udocker.py ps|cut -d" " -f 1|grep -v CONTAINER`
      fi
    done
done