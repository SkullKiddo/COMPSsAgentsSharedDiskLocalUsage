#!/bin/bash

#One liner chulo per parar tots els containers
#'$(docker ps --filter name="COMPSsWorker_docker_0*" --filter status=running -aq | xargs docker stop && compss_clean_procs)&'


# docker run \
#             --name="COMPSsWorker_docker_02" \
#             -d \
#             -p "46101:46101" \
#             -p "46102:46102" \
#             -v /opt/COMPSs:/opt/COMPSs \
#             -v /home/gpuigdem/compss_codes/test_dockers_agents/compss_execution_files:/compss_execution_files \
#             -v /home/gpuigdem/compss_codes/test_dockers_agents/agentsOut_2:/agentsOut \
#             --rm \
#             compss/compss /compss_execution_files/compss_commands_main_agent.sh

docker ps --filter name="COMPSsWorker_docker_0*" --filter status=running -aq | xargs docker stop && compss_clean_procs
sudo rm -rf /home/gpuigdem/compss_codes/test_dockers_agents/agentsOut_*

num_agents=$1

if [ -z "$num_agents" ]; then
    num_agents=1
fi

echo "______ creating $num_agents agents in docker containers"

for ((i=1; i <= num_agents; i++)); do


# No funciona porque entre docker y docker no puede comunicarse por 127.0.0.X no se por que
    # docker run \
    #     --name="COMPSsWorker_docker_0${i}" \
    #     -d \
    #     -p "127.0.0.$((i)):46$((i))01:46$((i))01" \
    #     -p "127.0.0.$((i)):46$((i))02:46$((i))02" \
    #     -v /opt/COMPSs:/opt/COMPSs \
    #     -v /home/gpuigdem/compss_codes/test_dockers_agents/compss_execution_files:/compss_execution_files \
    #     -v /home/gpuigdem/compss_codes/test_dockers_agents/agentsOut:/agentsOut \
    #     --rm \
    #     compss_agents /compss_execution_files/compss_commands_main_agent.sh ${i}
        
    docker run \
        --name="COMPSsWorker_docker_0${i}" \
        -d \
        --network host \
        -v /opt/COMPSs:/opt/COMPSs \
        -v /home/gpuigdem/compss_codes/test_dockers_agents/compss_execution_files:/compss_execution_files \
        -v /home/gpuigdem/compss_codes/test_dockers_agents/agentsOut:/agentsOut \
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

wait 


#One liner chulo per parar tots els containers
#'$(docker ps --filter name="COMPSsWorker_docker_0*" --filter status=running -aq | xargs docker stop && compss_clean_procs)&'
