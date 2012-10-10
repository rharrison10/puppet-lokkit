#!/bin/bash
# Check the contents of the lokkit config file for the lines provided as
# arguments to the script.

CONFIG_FILE=$1

if [ -f $CONFIG_FILE ] ; then
  # The remaining arguments should be strings to check for.
  shift
else
  echo "The first argument to $0 must be the config file to check" >&2
fi

for switch in "$@" ; do
  grep -q "^${switch}$" $CONFIG_FILE || {
    echo "${switch} not found in ${CONFIG_FILE}" >&2
    exit 1
  }
done

exit 0
