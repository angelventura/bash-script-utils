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


#
# UTIL
#

log.info.out "-------------------------------------------------------";
log.info.out "Testing UTIL ...";
assert.true " error.isOk $TRUE";
assert.true " error.isOk $EXIT_STATE_OK";
assert.false " error.isError $TRUE";
assert.false " error.isError $EXIT_STATE_OK";

assert.true " error.isError $FALSE";
assert.true " error.isError $EXIT_STATE_ERROR";
assert.false " error.isOk $FALSE";
assert.false " error.isOk $EXIT_STATE_ERROR";


#
# ARRAYS
#
log.info.out "-------------------------------------------------------";
log.info.out Testing array ...
util.load.library array;


array.create.value "pepe" "|" "a|b:c|d:E:f:G::D:";

if ! array.exists "pepe" ; then
	log.exception "PEPE";
fi

array.iterate "pepe" echo;

# array
array.add pepe uno;
array.add pepe dos;
array.add pepe tres;
array.add pepe cuatro;
array.add pepe cinco;

array.iterate pepe echo;

# hash
hash.add hpepe un Uno;
hash.add hpepe deux Dos;
hash.add hpepe trois Tres;
hash.add hpepe cuatre Cuatro;

assert.equal  "hash.get" "$(hash.get hpepe un)" "Uno";
assert.equal  "hash.get" "$(hash.get hpepe deux)" "Dos";
assert.equal  "hash.get" "$(hash.get hpepe trois)" "Tres";
assert.equal  "hash.get" "$(hash.get hpepe cuatre)" "Cuatro";

assert.true "hash.key.exist hpepe un";
assert.true "hash.key.exist hpepe deux";
assert.true "hash.key.exist hpepe trois";
assert.true "hash.key.exist hpepe cuatre";

assert.false "hash.key.exist hpepe 777";

echo KEYS: -------------
hash.iterate.keys hpepe echo;
echo VALUES: -------------
hash.iterate.values hpepe echo;

echo KEY,VALUE: -------------
hash.iterate hpepe echo;



batch.exitOK;
