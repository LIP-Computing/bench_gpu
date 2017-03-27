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
NVIDIA=QK5200
#NVIDIA=TK40
ROOT_DIR=/cloud/root

ROOT_INPUT_DIR=${ROOT_DIR}/bench-input
OUT_DIR=${ROOT_DIR}/bench-run5
R_OUT_DIR=${OUT_DIR}/results
T_OUT_DIR=${OUT_DIR}/time
PATH=${ROOT_DIR}/udocker:${PATH}

for OS in "C7" "U16"
do

    # Haddock Disvis and Powerfit
    if [ ${OS} = "C7" ]
    then
        DOCK_NAME=haddock-centos7-b5
    fi

    if [ ${OS} = "U16" ]
    then
        DOCK_NAME=haddock-ubuntu16.04-b5
    fi

    for EXEC in "docker" "udocker"
    do

        if [ ${EXEC} = "docker" ]
        then
            MACH="Dock-${OS}-${NVIDIA}"
        fi

        if [ ${EXEC} = "udocker" ]
        then
            MACH="UDock-${OS}-${NVIDIA}"
        fi


        #############################################################
        # From here on everyhting is fixed
        TIME="/usr/bin/time"
        TIME_STR="%e"
        DOCK_NVD="--device=/dev/nvidia0:/dev/nvidia0 \
                  --device=/dev/nvidiactl:/dev/nvidiactl \
                  --device=/dev/nvidia-uvm:/dev/nvidia-uvm"

        VDIR="-v ${ROOT_INPUT_DIR}:/home/input -v ${R_OUT_DIR}:/home/output"
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

            RESOUT=${R_OUT_DIR}/${MACH}/res-${CASE}
            TIMEOUT=${T_OUT_DIR}/${MACH}/time-${CASE}
            mkdir -p ${RESOUT}
            mkdir -p ${TIMEOUT}

            INPUT_DIR=/home/input/${CASEDIR}
            OUTPUT_DIR=/home/output/${MACH}/res-${CASE}
            PDB1=${INPUT_DIR}/${PDBF1}
            PDB2=${INPUT_DIR}/${PDBF2}
            REST=${INPUT_DIR}/restraints.dat

            echo "-> Input files: ${PDB1} ${PDB2} ${REST}"
            DOCK_RUN="${EXEC} run ${DOCK_OPT} ${DOCK_NAME}"

            for i in `seq -w ${NRUNS}`
            do
              for ANG in "10.0" "5.0"
              do
                for VS in "2" "1"
                do
                  if [ ${CASE} = "RNA-polymerase-II" && ${ANG} = "5.0" && ${VS} = "1" ]
                  then
                    continue
                  fi
                  TAG="ang-${ANG}-vs-${VS}-type-${TAG_TYPE}-n-${i}"
                  TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
                  OUT_DIR=${OUTPUT_DIR}/"res_${TAG}"
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

                  if [ ${EXEC} = "udocker" ]
                  then
                    udocker rm `udocker ps|cut -d" " -f 1|grep -v CONTAINER`
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

            RESOUT=${R_OUT_DIR}/${MACH}/res-${CASE}
            TIMEOUT=${T_OUT_DIR}/${MACH}/time-${CASE}
            mkdir -p ${RESOUT}
            mkdir -p ${TIMEOUT}

            INPUT_DIR=/home/input/${CASEDIR}
            OUTPUT_DIR=/home/output/${MACH}/res-${CASE}
            PDB=${INPUT_DIR}/${PDBF}
            MAP=${INPUT_DIR}/${MAPF}
            echo "-> Input files: ${PDB} ${MAP} Resolution: ${RESOL}"
            DOCK_RUN="${EXEC} run ${DOCK_OPT} ${DOCK_NAME}"

            for i in `seq -w ${NRUNS}`
            do
              TAG="ang-${ANG}-type-${TAG_TYPE}-n-${i}"
              TIME_RES=${TIMEOUT}/"tr_${TAG}.txt"
              OUT_DIR=${OUTPUT_DIR}/"res_${TAG}"
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

              if [ ${EXEC} = "udocker" ]
              then
                udocker rm `udocker ps|cut -d" " -f 1|grep -v CONTAINER`
              fi
            done
        done
    done
done
