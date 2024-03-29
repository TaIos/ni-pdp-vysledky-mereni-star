CPP_PROGRAM_TEMPLATE='main.template.cpp'
RUN_SCRIPT_TEMPLATE='../serial_job.template.sh'
CPP_COMPILE="g++"
CPP_FLAGS="--std=c++11 -O3 -funroll-loops -fopenmp"
QRUN_CMD="qrun2 20c 1 pdp_serial"
DATA_PATH="/home/saframa6/ni-pdp-semestralka/data"

createDirectory() {
	if [ ! -d ${1} ]
		then
		mkdir -p ${1}
	fi
}

cd ${1:-$(pwd)}

THRESHOLDS=(2 4 8 10 12)
INSTANCES=(7 10 12) # saj instance id
PROCNUMS=(1 2 4 6 8 10 16 20) # number of openmp cores
for THRESHOLD in ${THRESHOLDS[*]}
do
	OUT_DIR="out-t${THRESHOLD}"
	createDirectory ${OUT_DIR}
	for PROCNUM in ${PROCNUMS[*]}
	do
		for INSTANCE in ${INSTANCES[*]}
		do
			WORKDIR=$(realpath "${OUT_DIR}/saj${INSTANCE}-p${PROCNUM}-t${THRESHOLD}")
			createDirectory ${WORKDIR}

			CPP_PROGRAM=$(realpath "${WORKDIR}/main.cpp")
			EXE_PROGRAM=$(realpath "${WORKDIR}/run.out")
			RUN_SCRIPT=$(realpath "${WORKDIR}/openmp-job-saj${INSTANCE}-p${PROCNUM}-t${THRESHOLD}.sh")
			STDERR=$(realpath ${WORKDIR}/stderr)
			STDOUT=$(realpath ${WORKDIR}/stdout)
			touch ${STDERR} ${STDOUT}

			echo $WORKDIR
			echo -e "\tCPP program: ${CPP_PROGRAM}"
			echo -e "\tEXE program: ${EXE_PROGRAM}"
			echo -e "\tRUN script: ${RUN_SCRIPT}"

			sed "
				s/{PROCNUM}/$PROCNUM/g;
				s/{THRESHOLD}/${THRESHOLD}/g
				" ${CPP_PROGRAM_TEMPLATE} > ${CPP_PROGRAM}
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
