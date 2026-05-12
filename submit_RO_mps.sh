#!/bin/bash
#PBS -A ONRDC54450755
#PBS -l walltime=4:00:00
#PBS -q standard
#PBS -l select=1:ncpus=192:mpiprocs=1
#PBS -N L40_ro_mps
#PBS -m abe
#PBS -M hnpanboa@gmail.com
#PBS -r y
cd $HOME/CT_MPS
source ~/.bashrc
pyenv shell miniforge3-25.1.1-2
python post_analysis_traj_state_sum.py --L 40 --eps0 0.007 --eps1 0.0166
# cp traj_state_sum_O_L40_ro0.0070_0.0166.pickle $WORKDIR/Rp_quantum_classical/
# echo 'MPS L40 RO done'
