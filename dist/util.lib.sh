#!/bin/bash
#
# $HeadURL: http://svn/svn/estrada-gconf/scripts/utils/utils.sh $
# $Id: utils.sh 30 2009-07-14 13:38:57Z ventura $
#
# Utilidades para los scripts#
#

BSU_VERSION="beta";

function version(){
	echo $BSU_VERSION;
}


# PATH 
SCRIPTS_PATH="$(dirname "$0")"

if  [ "$LIB_PATH" == ""  ] ; then
	LIB_PATH="$SCRIPTS_PATH";
fi

# NAME of the executed SCRIPT
SCRIPT_NAME="$(basename "$0")"

#echo path:$SCRIPT_PATH

# Carga una libreria 
function loadLibrary(){
    local libraryName=$1'.sh';
    local librayPath=$LIB_PATH/lib/$libraryName;
    
    if [ ! -f "$librayPath" ]; then
		echo ERROR de instalacion no se encontro la biblioteca "$libraryName" en el path "$librayPath".
		exit $EXIT_STATE_ERROR;
    else
		. "$librayPath"
    fi    
}

# Librerias a cargar ...
loadLibrary conf;

loadLibrary log;
loadLibrary batch;
loadLibrary file_lib;

# Carga la configuracion local
    
if [ ! -f "$CONFIGURATION_FILE" ]; then
	msg="No se ha podido cargar la configuracion local: \"$CONFIGURATION_FILE\"";
	echo $msg;
	batch.exitError $msg;
else
	. "$CONFIGURATION_FILE"
	loadLibrary conf_lib;
	
fi    
