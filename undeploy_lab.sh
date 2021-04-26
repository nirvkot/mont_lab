#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_FILE="$(basename "$BASH_SOURCE")"
printf "Lab undeploy V0.1 strated at ${SCRIPT_DIR}/${SCRIPT_FILE}\n"
cd $SCRIPT_DIR
export ANSIBLE_CONFIG="ansible_root_keyauth.cfg"

ansible-playbook undeploy_ovirt_guests.yml

if [ $? -ne 0 ]; then
	printf "Error while undeploying ovirt guests. Exiting...\n"
	exit 1;
fi

# printf "Ovirt guetst have been successfully removed. Clearing inventory...\n"
# rm -rf group_vars host_vars inventory/lab_generated_inventory

printf "Undeploy lab done.\n"