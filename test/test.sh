#!/bin/bash
#
# $HeadURL:$
# $Id$
#
# Mains Tests
#

LIB_PATH="$(dirname "$0")";
BSU_PATH="$(dirname "$0")/../dist"
BSU_UTIL_LIB="$BSU_PATH/util.lib.sh"
DATE_FORMAT="+%y/%m/%d %H:%M:%S"

if [ ! -f "$BSU_UTIL_LIB" ]; then
    echo FATAL - `date "$DATE_FORMAT"`: Not BSU distribution found in path \"$BSU_UTIL_LIB\", pleae install the last one from "https://github.com/angelventura/bash-script-utils.git". Exit.
    exit 1;
else
    . $BSU_UTIL_LIB
fi

################
USAGE="This is to execute the unitary tests." 

batch.started $*;

util.load.library test;

assert.equal  "hash.get" "$(hash.get hpepe un)" "Uno";


batch.exitOK;
