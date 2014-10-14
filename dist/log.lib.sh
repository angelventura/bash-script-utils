#!/bin/bash
#
# $HeadURL:$
# $Id$
#
# Logs
#


# nivel de log
# DEBUG, INFO, WARN, ERROR

# Setting the default log level
if [ "$LOG_LEVEL" == "" ] ; then
	#LOG_LEVEL="DEBUG" 
	#LOG_LEVEL="INFO" 
	LOG_LEVEL="WARN" 
fi

# Formato para la fecha de los logs
DATE_FORMAT="+%y/%m/%d %H:%M:%S"

if [ "$LOG_ERROR_FILE" == "" ]; then
	LOG_ERROR_FILE="/dev/stderr";
	echo INFO - `date "$DATE_FORMAT"` - Ussing the default value for the stderr.
fi

if [ "$LOG_OUT_FILE" == "" ]; then
	LOG_OUT_FILE="/dev/stdout";
	echo INFO - `date "$DATE_FORMAT"` - Ussing the default value for stdout.
fi


# EXCEPTIONS
#shopt -s expand_aliases
#alias exception='log.exception $*; return $FALSE;'


function log.debug() {
	if [ "$LOG_LEVEL" == "DEBUG" ] ; then 
		_log $LOG_OUT_FILE debug ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
    fi	
}

function log.info(){
    if [ "$LOG_LEVEL" == "DEBUG" ] || [ "$LOG_LEVEL" == "INFO" ] ; then 
		_log $LOG_OUT_FILE Info ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
    fi
}

function log.info.out(){
    if [ "$LOG_LEVEL" == "DEBUG" ] || [ "$LOG_LEVEL" == "INFO" ] ; then 
		_log $LOG_OUT_FILE Info ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
    fi
	echo -e Info: $*;
}

function log.warn(){
    if [ "$LOG_LEVEL" == "DEBUG" ] || [ "$LOG_LEVEL" == "INFO" ] || [ "$LOG_LEVEL" == "WARN" ] ; then 
		_log $LOG_OUT_FILE Warn ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
    fi
}

function log.warn.out(){
    if [ "$LOG_LEVEL" == "DEBUG" ] || [ "$LOG_LEVEL" == "INFO" ] || [ "$LOG_LEVEL" == "WARN" ] ; then 
		_log $LOG_OUT_FILE Warn ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
    fi
	echo -e WARN: $*;
}

function log.error(){	
    _log $LOG_ERROR_FILE ERROR ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
}

function log.fatal(){
    _log $LOG_ERROR_FILE FATAL ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
}

function log.error.out(){
    _log $LOG_ERROR_FILE ERROR ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*
	echo -e ERROR: $*;
}

function log.exception(){	
    _log $LOG_ERROR_FILE EXCEPTION ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*

	local len=${#FUNCNAME[@]}

	# el 0 es el actual ...
	for (( i=2; i<${len}; i++ )); do
		_log $LOG_ERROR_FILE EXCEPTION ${FUNCNAME[$i]}[`basename ${BASH_SOURCE[$i]}`:${BASH_LINENO[$i-1]}]; 
	done
}

function log.trace(){	
    _log $LOG_ERROR_FILE TRACE ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*

	local len=${#FUNCNAME[@]}

	# el 0 es el actual ...
	for (( i=2; i<${len}; i++ )); do
		_log $LOG_ERROR_FILE TRACE ${FUNCNAME[$i]}[`basename ${BASH_SOURCE[$i]}`:${BASH_LINENO[$i-1]}]; 
	done
}

function log.exception.out(){	
    _log $LOG_ERROR_FILE EXCEPTION ${FUNCNAME[1]}[`basename ${BASH_SOURCE[1]}`:${BASH_LINENO[0]}]: $*

	local len=${#FUNCNAME[@]}

	# el 0 es el actual ...
	for (( i=2; i<${len}; i++ )); do
		_log $LOG_ERROR_FILE EXCEPTION ${FUNCNAME[$i]}[`basename ${BASH_SOURCE[$i]}`:${BASH_LINENO[$i-1]}]; 
	done

	echo -e EXCEPTION: $*;
}


function _log(){
	local inner_log_file="$1";

    if [ "$inner_log_file" ]; then
		local level="$2";
		shift 2;
		echo $level - `date "$DATE_FORMAT"` - $* >> $inner_log_file
    else
		echo FATAL - `date "$DATE_FORMAT"`: no hay definido un fichero de error "$inner_log_file" para los logs
		echo FATAL - `date "$DATE_FORMAT"` - "Batch terminado."
		exit $EXIT_STATE_ERROR;
    fi
}