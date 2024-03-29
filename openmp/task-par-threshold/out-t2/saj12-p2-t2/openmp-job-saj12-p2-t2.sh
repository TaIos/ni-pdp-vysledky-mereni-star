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

# Request Bourne shell as shell for job
#$ -S /bin/sh

# Execute the job from the current working directory.
#$ -cwd

# Defines  or  redefines  the  path used for the standard error stream of the job.
#$ -e /home/saframa6/testing/openmp/task-par-threshold/out-t2/saj12-p2-t2/stderr

# The path used for the standard output stream of the job.
#$ -o /home/saframa6/testing/openmp/task-par-threshold/out-t2/saj12-p2-t2/stdout

# Do not change.
#$ -pe ompi 1

/home/saframa6/testing/openmp/task-par-threshold/out-t2/saj12-p2-t2/run.out /home/saframa6/ni-pdp-semestralka/data/saj12.txt
