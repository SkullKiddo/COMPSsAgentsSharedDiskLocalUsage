#!/bin/bash

# SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# compss_execution_files=${SCRIPT_DIR}



agent_num=${1}
if [ -z "$num_agents" ]; then
    num_agents=1
fi

agentOut="/agentsOut/agent_${agent_num}"
wdir="${agentOut}/wdir"
log="${agentOut}/log"

mkdir -p ${wdir}
mkdir -p ${log}



/opt/COMPSs/Runtime/scripts/user/compss_agent_start \
    -d \
    --wdir="${wdir}" \
    --pythonpath="/compss_execution_files" \
    --hostname="COMPSsWorker0${agent_num}" \
    --log_dir="${log}" \
    --resources="compss_execution_files/resources.xml" \
    --project="compss_execution_files/projectAgent${agent_num}.xml" \
    --rest_port="46${agent_num}01" \
    --comm_port="46${agent_num}02"    1>${agentOut}/COMPSsWorker0${agent_num}.outputlog 2>${agentOut}/COMPSsWorker0${agent_num}.errorlog


