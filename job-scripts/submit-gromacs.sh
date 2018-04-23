#!/bin/bash
########### Examples of batch system options for job submition
# #$ -l gpu
# #$ -l release=el7
# #$ -P HpcGrid
######################################

# STORE Put the shared dir with worker nodes
STORE=$HOME

# Execution mode for udocker - see documentation
EMODE=F3

PATH=${STORE}/bin:$PATH
UDOCKER_DIR=${STORE}/.udocker
CONT=gr2018
WDIR=`pwd`

echo $PATH
echo $UDOCKER_DIR
echo "----------------"

echo "Doing the setup"
udocker setup --execmode=${EMODE} --nvidia ${CONT}

echo "RUNNING"
udocker run -w /home ${CONT} gmx mdrun -s /home/md.tpr -ntomp 1 -gpu_id 0

