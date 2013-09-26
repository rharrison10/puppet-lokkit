#!/bin/bash

ORIG_FILE=$1
COMP_FILE=$2
RETURN_CODE=0

if [ ! -r $ORIG_FILE ] ; then
  echo "%{ORIG_FILE} is not a file that can be read" >&2
  exit 1
fi

if [ ! -r $COMP_FILE ] ; then
  echo "%{COMP_FILE} is not a file that can be read" >&2
  exit 1
fi

SORTED_ORIG=`mktemp --tmpdir orig.XXXXXXXXXX`

sort $ORIG_FILE > $SORTED_ORIG 2> /dev/null

SORTED_COMP=`mktemp --tmpdir comp.XXXXXXXXXX`

sort $COMP_FILE > $SORTED_COMP 2> /dev/null

diff -q $SORTED_ORIG $SORTED_COMP &> /dev/null || {
  RETURN_CODE=$?
}

# Clean up temp files
rm -f $SORTED_ORIG $SORTED_COMP

exit $RETURN_CODE
