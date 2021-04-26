#!/bin/bash

read_var_from_file() {
  #reads value of specified variable from specified config(conf, ini, txt ...) files
  # $1 - file path
  # $2 - variable name

  (grep -E "^${2}=" -m 1 "${1}" 2>/dev/null || echo "VAR=__UNDEFINED__") | head -n 1 | cut -d '=' -f 2- | sed -e 's/^"//' -e 's/"$//';
  # explanation:
  # head - reads first string(grep may return more than one match)
  # cut - cuts all to the right of "=" (-d - delimeter -f <number_of_field> - after number to capture all fields(delimeted values) after second)
  # set - gets rid of quotes
}

write_var_to_file() {
  # writes new value of variable to specified config(conf, ini, txt ...) files
  # $1 - file path
  # $2 - variable name
  # $3 - new value
  # $4 - assignment operator (default is ': ' as we work with yaml)

  new_value=\"$3\"

  if [ -z "$4" ]; then
    assign_optr=": "
  else
    assign_optr=$4
  fi

  if grep -Fq "$2" $1
  then
    #if variable is found in file replace it's value with sed
    sed -c -i "s/\($2 *${assign_optr} *\).*/\1$new_value/" $1
  else
    #if var not found - append it to file
    echo "${2}${assign_optr}${new_value}" >> $1
  fi
}


load_config() {
  # loads config file with source command
  # $1 - config file path relative to script home directory

  configFPath=$1

  if [[ -z $configFPath ]]
  then
    echo "Config path must be set to read config.";
    return 1
  fi

  if [ ! -f $configFPath ]; then
      echo "File $configFPath doesn't exist or could not be opened."
      return 1
  fi

  echo "Reading config at: $configFPath"

  # now source it, either the original or the filtered variant
  source "$configFPath"
}