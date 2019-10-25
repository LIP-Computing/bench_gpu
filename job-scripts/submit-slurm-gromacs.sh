#!/bin/bash

#SBATCH --partition=shortterm
#SBATCH --ntasks=4
#SBATCH --nodes=1
#SBATCH --ntasks-per-core=1 

echo "----------------"
env|sort
echo "----------------"
uname -a
hostname
echo

mkdir -p $SLURM_SUBMIT_DIR/ncpu_${SLURM_NPROCS}-${SLURM_JOB_ID}
cd $SLURM_SUBMIT_DIR/ncpu_${SLURM_NPROCS}-${SLURM_JOB_ID}

module load Programs/gromacs/2019.3/with_OpenMPI_4.0.1-with_GCC_4.8.5
mpirun -np ${SLURM_NTASKS} gmx_mpi mdrun -s $SLURM_SUBMIT_DIR/md.tpr -ntomp 1 

