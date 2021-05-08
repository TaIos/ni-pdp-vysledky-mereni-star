CPP_PROGRAM_TEMPLATE='main.template.cpp'
RUN_SCRIPT_TEMPLATE='serial_job.template.sh'
OUT_DIR="out"
CPP_COMPILE="g++"
CPP_FLAGS="--std=c++11 -O3 -funroll-loops -fopenmp"
QRUN_CMD='qrun2 20c 1 pdp_serial'

createDirectory() {
	if [ ! -d ${1} ]
		then
		mkdir -p ${1}
	fi
}

createDirectory ${OUT_DIR}

INSTANCES=(7 10 12)
PROCNUMS=(1 2 4 6 8 1 16 20)
for INSTANCE in ${INSTANCES[*]}
do
	for PROCNUM in ${PROCNUMS[*]}
	do
		WORKDIR="${OUT_DIR}/saj${INSTANCE}-p${PROCNUM}"
		createDirectory ${WORKDIR}

		CPP_PROGRAM="${WORKDIR}/main.cpp"
		EXE_PROGRAM="${WORKDIR}/run.out"
		RUN_SCRIPT="${WORKDIR}/openmp-job-saj${INSTANCE}-p${PROCNUM}.sh"

		echo $WORKDIR
		echo -e "\tCPP program: ${CPP_PROGRAM}"
		echo -e "\tEXE program: ${EXE_PROGRAM}"
		echo -e "\tRUN script: ${RUN_SCRIPT}"

		sed "s/{PROCNUM}/$PROCNUM/g" ${CPP_PROGRAM_TEMPLATE} > ${CPP_PROGRAM}
		echo -e "\tCOMPILE: ${CPP_COMPILE} ${CPP_FLAGS} ${CPP_PROGRAM} -o ${EXE_PROGRAM}"
		${CPP_COMPILE} ${CPP_FLAGS} ${CPP_PROGRAM} -o ${EXE_PROGRAM}

		sed "s|{INSTANCE}|$INSTANCE|g; s|{PROCNUM}|$PROCNUM|g;" ${RUN_SCRIPT_TEMPLATE} > ${RUN_SCRIPT}
		echo -e "\tQRUN: ${QRUN_CMD} ${RUN_SCRIPT}"
		touch ${WORKDIR}/{stderr,stdout}

		currentDir=$PWD
		cd ${WORKDIR}
		${QRUN_CMD} $(basename ${RUN_SCRIPT})
		cd ${currentDir}

		echo "============================="
		exit 0
	done
done

echo "DONE"
exit 0
