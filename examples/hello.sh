#!/bin/bash
#
# $HeadURL: $
# $Id$
#
# Hello Wolrd
#

LIB_PATH="$(dirname "$0")";
BSU_PATH="$(dirname "$0")/../dist";
BSU_UTIL_LIB="$BSU_PATH/util.lib.sh";
DATE_FORMAT="+%y/%m/%d %H:%M:%S";

if [ ! -f "$BSU_UTIL_LIB" ]; then
    echo FATAL - `date "$DATE_FORMAT"`: Not BSU distribution found in path \"$BSU_UTIL_LIB\", pleae install the last one from "https://github.com/angelventura/bash-script-utils.git". Exit.
    exit 1;
else
    . $BSU_UTIL_LIB;
fi

################
USAGE="This just say hello" ;


batch.started $*;

log.info.out "Hello wolrd!";

batch.exitOK;
