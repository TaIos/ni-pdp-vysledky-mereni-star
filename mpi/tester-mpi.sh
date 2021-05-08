CPP_PROGRAM_TEMPLATE='main.template.cpp'
RUN_SCRIPT_TEMPLATE='parallel_job.template.sh'
CPP_COMPILE="mpicxx"
CPP_FLAGS="--std=c++11 -lm -O3 -funroll-loops -fopenmp"
QRUN_CMD_TEMPLATE="qrun2 20c {NODENUM} pdp_fast"  # pdp_fast/pdp_long
DATA_PATH="/home/saframa6/ni-pdp-semestralka/data"

createDirectory() {
	if [ ! -d ${1} ]
		then
		mkdir -p ${1}
	fi
}

cd ${1:-$(pwd)}
OUT_DIR="out$(find . -mindepth 1 -maxdepth 1 | sed 's/^\.\///g' | grep -P '^out\d*$' | wc -l)"

createDirectory ${OUT_DIR}

INSTANCES=(7 10 12) # saj instance id
PROCNUMS=(1 2 4 6 8 10 16 20) # number of openmp cores
NODENUMS=(3 4) # total number of MPI nodes
for INSTANCE in ${INSTANCES[*]}
do
	for PROCNUM in ${PROCNUMS[*]}
	do
		for NODENUM in ${NODENUMS[*]}
		do
			WORKDIR=$(realpath "${OUT_DIR}/saj${INSTANCE}-n${NODENUM}-p${PROCNUM}")
			createDirectory ${WORKDIR}

			CPP_PROGRAM=$(realpath "${WORKDIR}/main.cpp")
			EXE_PROGRAM=$(realpath "${WORKDIR}/run.out")
			RUN_SCRIPT=$(realpath "${WORKDIR}/mpi-job-saj${INSTANCE}-n${NODENUM}-p${PROCNUM}.sh")
			STDERR=$(realpath ${WORKDIR}/stderr)
			STDOUT=$(realpath ${WORKDIR}/stdout)
			touch ${STDERR} ${STDOUT}

			echo $WORKDIR
			echo -e "\tCPP program: ${CPP_PROGRAM}"
			echo -e "\tEXE program: ${EXE_PROGRAM}"
			echo -e "\tRUN script: ${RUN_SCRIPT}"

			QRUN_CMD=$(sed "s/{NODENUM}/${NODENUM}/g"  <<< ${QRUN_CMD_TEMPLATE})

			sed "s/{PROCNUM}/$PROCNUM/g" ${CPP_PROGRAM_TEMPLATE} > ${CPP_PROGRAM}
			
			echo -e "\tCOMPILE: ${CPP_COMPILE} ${CPP_FLAGS} ${CPP_PROGRAM} -o ${EXE_PROGRAM}"
			${CPP_COMPILE} ${CPP_FLAGS} ${CPP_PROGRAM} -o ${EXE_PROGRAM}

			sed "
				s|{EXE_PROGRAM}|$EXE_PROGRAM|g;
				s|{ARGUMENTS}|$DATA_PATH/saj$INSTANCE.txt|g;
				s|{STDOUT}|$STDOUT|g;
				s|{STDERR}|$STDERR|g;
				" ${RUN_SCRIPT_TEMPLATE} > ${RUN_SCRIPT}
			echo -e "\tQRUN: ${QRUN_CMD} ${RUN_SCRIPT}"

			${QRUN_CMD} ${RUN_SCRIPT}
			echo "============================="
		done
	done
done

echo "DONE"
exit 0
