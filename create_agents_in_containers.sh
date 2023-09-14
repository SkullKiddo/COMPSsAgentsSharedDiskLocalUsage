#!/bin/bash

#One liner chulo per parar tots els containers
#'$(docker ps --filter name="COMPSsWorker_docker_0*" --filter status=running -aq | xargs docker stop && compss_clean_procs)&'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker ps --filter name="COMPSsWorker_docker_0*" --filter status=running -aq | xargs docker stop && compss_clean_procs
sudo rm -rf ${SCRIPT_DIR}/agentsOut_*

num_agents=$1

if [ -z "$num_agents" ]; then
    num_agents=1
fi

echo "______ creating $num_agents agents in docker containers"

for ((i=1; i <= num_agents; i++)); do

    docker run \
        --name="COMPSsWorker_docker_0${i}" \
        -d \
        --network host \
        -v /opt/COMPSs:/opt/COMPSs \
        -v ${SCRIPT_DIR}/compss_execution_files:/compss_execution_files \
        -v ${SCRIPT_DIR}/agentsOut:/agentsOut \
        --rm \
        compss_agents /compss_execution_files/compss_commands_main_agent.sh ${i}

    sleep 1
done

sleep 

for ((i=1; i <= num_agents-1; i++)); do
/opt/COMPSs/Runtime/scripts/user/compss_agent_add_resources \
    --agent_node="COMPSsWorker0${i}" \
    --agent_port="46${i}01" \
    --comm="es.bsc.compss.agent.comm.CommAgentAdaptor" \
    --cpu=1 \
    "COMPSsWorker0$((i+1))" "Port=46$((i+1))02"
    sleep 1
done


sleep 10

param_forward_to=""
if [ "$num_agents" -gt "1" ]; then
    for ((i=2; i <= num_agents; i++)); do
        param_forward_to=${param_forward_to}"COMPSsWorker0${i}:46${i}01;"
    done
    param_forward_to="${param_forward_to::-1}"
fi

echo "/opt/COMPSs/Runtime/scripts/user/compss_agent_call_operation \
    --lang=PYTHON \
    --method_name=main_agents \
    --master_node=COMPSsWorker01 \
    --master_port=46101 \
    --stop \
    --forward_to='${param_forward_to}' \
    test"

/opt/COMPSs/Runtime/scripts/user/compss_agent_call_operation \
    --lang=PYTHON \
    --method_name=main_agents \
    --master_node=COMPSsWorker01 \
    --master_port=46101 \
    --stop \
    --forward_to="${param_forward_to}" \
    test



#One liner chulo per parar tots els containers
#'$(docker ps --filter name="COMPSsWorker_docker_0*" --filter status=running -aq | xargs docker stop && compss_clean_procs)&'
