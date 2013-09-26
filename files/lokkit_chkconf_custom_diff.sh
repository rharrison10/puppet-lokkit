#!/bin/bash
# Check to make sure all the custom rules files are the same or have changed.
FILE_CMD='/usr/local/bin/lokkit_chkconf_diff.sh'
LOKKIT_CONF=''
FILE_POSTFIX=''
RETURN_CODE=0
SCRIPTNAME=`basename $0`

usage() {
  echo -e "\nUsage: $SCRIPTNAME -c <lokkitconfig> -p <filepostfix> [OPTION]
Options:
  -c, --config   The location of the lokkit config file.
                 Usually /etc/sysconfig/system-config-firewall

  --copy         Copy the files from their current names to their name with
                 the postix appended instead of compairing them.

  -p, --postfix  The postfix to append to the file for copying or compairing
"
}
GETOPT_TMP=`getopt -o c:hp: -l config:,copy,help,postfix: -- "$@"`
[ "$?" == "0" ] || usage
eval set -- "$GETOPT_TMP"

while [ ! -z "$1" ] ; do
  case "$1" in
    --config|-c)
      LOKKIT_CONF=$2
      shift
    ;;
    --copy)
      FILE_CMD='cp -f'
    ;;
    --postfix|-p)
      FILE_POSTFIX=$2
      shift
    ;;
    *) break ;;
  esac
  shift
done

if [ -z "$LOKKIT_CONF" -o -z "FILE_POSTFIX" ] ; then
  echo -e "You must provide a config file and the custom file postfix\n" >&2
  usage
  exit 1
fi

for custom_file in `grep 'custom-rules=' $LOKKIT_CONF | cut -d ':' -f 3-` ; do
  [ -f ${custom_file} ] || touch ${custom_file}
  [ -f ${custom_file}${FILE_POSTFIX} ] || touch ${custom_file}${FILE_POSTFIX}
  $FILE_CMD ${custom_file} ${custom_file}${FILE_POSTFIX} || exit 1
done

exit $RETURN_CODE
