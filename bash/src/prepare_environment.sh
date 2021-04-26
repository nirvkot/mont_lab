#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_FILE="$(basename "$BASH_SOURCE")"
printf "Prepare environment strated at ${SCRIPT_DIR}/${SCRIPT_FILE}\n"
cd $SCRIPT_DIR

#config management "lib"
source ../funcs/config.sh
#inventory "lib"
source ../funcs/inventory.sh

#all global variables for main routine defined in config file
config_file_path="../../mont_lab.conf"

#load config
load_config $config_file_path
if [ $? -ne 0 ]; then
	printf "error reading config at ${config_file_path}\n"
	exit 1;
fi

printf "Preparing lab environment for mont lab...\n"

prepare_inventory