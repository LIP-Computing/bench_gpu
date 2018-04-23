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
CONT=tf150
WDIR=`pwd`

echo $PATH
echo $UDOCKER_DIR
echo "----------------"

echo "Doing the setup"
udocker setup --execmode=${EMODE} --nvidia ${CONT}

echo "RUNNING"
udocker run -w /home/tf-benchmarks ${CONT} /home/tf-benchmarks/run-bench.sh all

