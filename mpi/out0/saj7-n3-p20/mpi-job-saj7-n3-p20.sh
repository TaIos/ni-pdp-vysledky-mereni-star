#!/bin/sh

#  ===========================================================================
# |                                                                           |
# |             COMMAND FILE FOR SUBMITTING SGE JOBS                          |
# |                                                                           |
# |                                                                           |
# | SGE keyword statements begin with #$                                      |
# |                                                                           |
# | Comments begin with #                                                     |
# | Any line whose first non-blank character is a pound sign (#)              |
# | and is not a SGE keyword statement is regarded as a comment.              |
#  ===========================================================================

#  ===========================================================================
# |                                                                           |
# | Request Bourne shell as shell for job                                     |
# |                                                                           |
#  ===========================================================================
#$ -S /bin/bash

#  ===========================================================================
# |                                                                           |
# | Execute the job from the current working directory.                       |
# |                                                                           |
#  ===========================================================================
#$ -cwd

#  ===========================================================================
# |                                                                           |
# | Defines or redefines the path used for the standard error stream          |
# | of the job.                                                               |
# |                                                                           |
#  ===========================================================================
#$ -e /home/saframa6/testing/mpi/out0/saj7-n3-p20/stderr

#  ===========================================================================
# |                                                                           |
# | The path used for the standard output stream of the job.                  |
# |                                                                           |
#  ===========================================================================
#$ -o /home/saframa6/testing/mpi/out0/saj7-n3-p20/stdout

#  ===========================================================================
# |                                                                           |
# | Specifies that all environment variables active within the qsub utility   |
# | be exported to the context of the job.                                    |
# |                                                                           |
#  ===========================================================================
#$ -V

#  ===========================================================================
# |                                                                           |
# | Set network communications - over Ethernet or InfiniBand.                 |
# |   false - Network communications over Ethernet                            |
# |   true  - Network communications over Infniband                           |
# |                                                                           |
#  ===========================================================================
INFINIBAND="false"

#  ===========================================================================
# |                                                                           |
# | Parallel program with arguments.                                          |
# |                                                                           |
#  ===========================================================================
MY_PARALLEL_PROGRAM="/home/saframa6/testing/mpi/out0/saj7-n3-p20/run.out /home/saframa6/ni-pdp-semestralka/data/saj7.txt"

#  ===========================================================================
# |                                                                           |
# | Export environment variable to execution nodes                            |
# |                                                                           |
#  ===========================================================================
# export MY_VARIABLE2="..."


# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#  ===========================================================================
# |                                                                           |
# | !!! Do not change !!!                                                     |
# | mpirun -np $NSLOTS                                                        |
# | !!! Do not change !!!                                                     |
# |                                                                           |
#  ===========================================================================

if [[ ${INFINIBAND} = "true" ]]
then
  #  -------------------------------------------------------------------------
  # | Set network communication openMPI between nodes - InfiniBand (openib)   |
  #  -------------------------------------------------------------------------
#  mpirun -np $NSLOTS --report-bindings ${MY_PARALLEL_PROGRAM}
  mpirun -np $NSLOTS ${MY_PARALLEL_PROGRAM}
else
  #  -------------------------------------------------------------------------
  # | Set network communication openMPI between nodes - Ethernet (tcp)        |
  #  -------------------------------------------------------------------------
#  mpirun --mca btl tcp,self -np $NSLOTS --report-bindings ${MY_PARALLEL_PROGRAM}
  mpirun --mca btl tcp,self -np $NSLOTS ${MY_PARALLEL_PROGRAM}
fi
