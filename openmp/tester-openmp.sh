CPP_PROGRAM_TEMPLATE='main.template.cpp'
RUN_SCRIPT_TEMPLATE='../serial_job.template.sh'
OUT_DIR="out"
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

createDirectory ${OUT_DIR}

INSTANCES=(7 10 12)
PROCNUMS=(1 2 4 6 8 1 16 20)
for INSTANCE in ${INSTANCES[*]}
do
	for PROCNUM in ${PROCNUMS[*]}
	do
		WORKDIR=$(realpath "${OUT_DIR}/saj${INSTANCE}-p${PROCNUM}")
		createDirectory ${WORKDIR}

		CPP_PROGRAM=$(realpath "${WORKDIR}/main.cpp")
		EXE_PROGRAM=$(realpath "${WORKDIR}/run.out")
		RUN_SCRIPT=$(realpath "${WORKDIR}/openmp-job-saj${INSTANCE}-p${PROCNUM}.sh")
		STDERR=$(realpath ${WORKDIR}/stderr)
		STDOUT=$(realpath ${WORKDIR}/stdout)
		touch ${STDERR} ${STDOUT}

		echo $WORKDIR
		echo -e "\tCPP program: ${CPP_PROGRAM}"
		echo -e "\tEXE program: ${EXE_PROGRAM}"
		echo -e "\tRUN script: ${RUN_SCRIPT}"

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

echo "DONE"
exit 0
