#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_FILE="$(basename "$BASH_SOURCE")"
printf "Lab deploy V0.1 strated at ${SCRIPT_DIR}/${SCRIPT_FILE}\n"
cd $SCRIPT_DIR

bash/src/prepare_environment.sh

cd $SCRIPT_DIR

printf "Maping external users from file...\n"

ansible-playbook map_external_users.yml

if [ $? -ne 0 ]; then
	printf "Error while mapping ext users. Exiting...\n"
	exit 1;
fi


printf "Preparing ovirt guests...\n"

ansible-playbook deploy_ovirt_guests.yml

if [ $? -ne 0 ]; then
	printf "Error while deploying ovirt guests. Exiting...\n"
	exit 1;
fi

printf "Collecting ovirt hostvars...\n"
ansible-playbook obtain_vm_ips.yml

if [ $? -ne 0 ]; then
	printf "Error while collecting ovirt hostvars. Exiting...\n"
	exit 1;
fi

printf "Configuring lab vms...\n"
ansible-playbook lab_vms.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring lab vms. Exiting...\n"
	exit 1;
fi

printf "Vm repos and packages...\n"
ansible-playbook lab_vms_packages.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring Vms packages. Exiting...\n"
	exit 1;
fi

printf "Workstation specific config...\n"
ansible-playbook lab_vms_workstations.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring WS vms. Exiting...\n"
	exit 1;
fi

printf "Node specific config...\n"
ansible-playbook lab_vms_nodes.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring node vms. Exiting...\n"
	exit 1;
fi

printf "Core authenticated keys...\n"
ansible-playbook lab_core_keys.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring core keys. Exiting...\n"
	exit 1;
fi

printf "\n=====> General lab config done. Starting lab unit specific tasks.\n"

printf "Configuring stratis...\n"
ansible-playbook workshop_units_playbooks/stratis_preparation.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring stratis. Exiting...\n"
	exit 1;
fi

printf "Configuring boom...\n"
ansible-playbook workshop_units_playbooks/boom_preparation.yml

if [ $? -ne 0 ]; then
	printf "Error while configuring boom. Exiting...\n"
	exit 1;
fi

printf "\n=====> Lab config done. Configuring ovirt lab users.\n"
ansible-playbook lab_users.yml

if [ $? -ne 0 ]; then
	printf "Error configuring lab users. Exiting...\n"
	exit 1;
fi

printf "\n***Basic lab deploy .. done!***\n"