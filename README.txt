The script "create_agents_in_containers.sh <n>" lanches $n dockers which each one executing compss_commands_main_agent.sh parametized with the number of the agent (from now on let's call this id number for each agent between 1..n  "i").

The docker are launched with the folder compss_execution_files mounted as a volume for them to read the script that starts the agent (compss_commands_main_agent), the configuration files, and the code of the execution. 

Each docker is spawned with the output mounted to a diferent volume (agentsOut/agent_$i).

compss_commands_main_agent.sh takes this $i parameter for each agent to start inside their own docker with the project xml projectAgent$i.xml (we need to create more xmls if we want more than 3 agents).

The project xmls are configured for the agents to have a shared disk.

The main script (create_agents_in_containers.sh) will then asign the agents as resources to eachother in a chain topology.

Finally, the main script launches the execution on the main (i=1) agent.

The dockers do NOT die after the execution but the agents do.

The output of each agent will be stored in agentsOut in this folder.

A good idea to test in depth the shared disk functionality is to modify this script to launch all the tests of the agent_transfers family.

A way to check if the agents are using or not the shared capabilities is to search the logs for the regex "(Finished sending)(?!.*Ping)" and check if the agents are sending the data or not.