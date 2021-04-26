#!/bin/bash

prepare_inventory() {
  # generates inventory and saves it to inventory file
  # all variables used obtained from config file 
  #TODO: parse params with getopt(?)
  # printf "Generating inventory for ${1} students and ${2} nodes per student...\n"
  lab_inventory_filepath="${lab_ans_cfg_path}${lab_inventory_filename}"
  control_vm_group="[${control_vm_group_name}]"
  node_vm_group="[${node_vm_group_name}]"
  content_vm_group="[${content_vm_group_name}]\n${content_vm_name}${vm_domain_part}"
  $(> ${lab_inventory_filepath})
  declare -a stud_groups_array

  for ((i = 1 ; i <= students_count ; i++ ));
  do
    control_vm_name="${conrol_vm_name_template}${i}-ws${vm_domain_part}"
    control_vm_group="${control_vm_group}\n${control_vm_name}"
    cur_stud="student${i}"
    cur_stud_group_name="vms_${cur_stud}"
    cur_stud_group="\n[${cur_stud_group_name}]\n${control_vm_name}"
    set_host_var $control_vm_name "lab_fqdn" "${lab_control_vm_name}${lab_domain_part}"
    set_host_var $control_vm_name "short_fqdn" "${lab_control_vm_name}"
    for ((j = 1 ; j <= nodes_per_student ; j++ ));
    do
      node_vm_name="${node_vm_name_template}${i}-node${j}${vm_domain_part}"
      node_vm_group="${node_vm_group}\n${node_vm_name}"
      cur_stud_group="${cur_stud_group}\n${node_vm_name}"
      set_host_var $node_vm_name "lab_fqdn" "${lab_node_vm_name}${j}${lab_domain_part}"
      set_host_var $node_vm_name "short_fqdn" "${lab_node_vm_name}${j}"
    done
    stud_groups_array+=("$cur_stud_group\n")
    set_group_var $cur_stud_group_name "owner" $cur_stud
    set_group_var $cur_stud_group_name "owner_number" $i
  done

  set_group_var $control_vm_group_name "template" $control_vm_template_name
  set_group_var $control_vm_group_name "type" "ws"
  set_group_var $node_vm_group_name "template" $node_vm_template_name
  set_group_var $node_vm_group_name "type" "node"
  set_group_var $content_vm_group_name "type" "core"
  set_host_var ${content_vm_name}${vm_domain_part} "lab_fqdn" "${lab_content_vm_name}${lab_domain_part}"
  set_host_var ${content_vm_name}${vm_domain_part} "short_fqdn" "${lab_content_vm_name}"
  set_host_var ${content_vm_name}${vm_domain_part} "ansible_user" "${content_vm_ansible_user}"
  set_host_var ${content_vm_name}${vm_domain_part} "ansible_password" "${content_vm_ansible_password}"
  set_host_var ${content_vm_name}${vm_domain_part} "ansible_become" "true"

  printf $content_vm_group >> $lab_inventory_filepath
  printf "\n\n" >> $lab_inventory_filepath
  printf $control_vm_group >> $lab_inventory_filepath
  printf "\n\n" >> $lab_inventory_filepath
  printf $node_vm_group >> $lab_inventory_filepath
  printf "\n" >> $lab_inventory_filepath
  for i in "${stud_groups_array[@]}"; do printf "$i" >> $lab_inventory_filepath; done
  printf "\n[lab_vms:children]\nworkstations\nnodes" >> $lab_inventory_filepath
}

set_group_var() {
#setsgroupvar $2 with value $3 for $1 groupname
  group_dirpath="${lab_ans_cfg_path}${groupvars_foldername}/$1"
  if [ ! -d "${group_dirpath}" ];then
     mkdir -p "${group_dirpath}"
  fi 
    if [ ! -f "${group_dirpath}/vars.yml" ];then
     touch "${group_dirpath}/vars.yml"
  fi 
  write_var_to_file "${group_dirpath}/vars.yml" $2 $3
}

set_host_var() {
  #sets hostvar $2 with value $3 for $1 hostname
  host_dirpath="${lab_ans_cfg_path}${hostvars_foldername}/$1"
  if [ ! -d "${host_dirpath}" ];then
     mkdir -p "${host_dirpath}"
  fi 
  if [ ! -f "${host_dirpath}/vars.yml" ];then
     touch "${host_dirpath}/vars.yml"
  fi 
  write_var_to_file "${host_dirpath}/vars.yml" $2 $3
}