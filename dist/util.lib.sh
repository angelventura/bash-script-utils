#!/bin/bash
#
# $HeadURL: $
# $ utils.lob.sh $
#
# General utils
#

# NAME of the executed SCRIPT
SCRIPT_NAME="$(basename "$0")"
SCRIPT_PATH="$(dirname "$0")"

BSU_VERSION="beta";

function version(){
	echo $BSU_VERSION;
}

if [ "$BSU_PATH" == "" ] ; then 
	BSU_PATH="$(dirname "$0")""/dist";
	echo WARN -  BSU_PATH not defined using the default one: $BSU_PATH;
fi

# loading a library
function util.load.library(){
    local libraryName="$1"'.lib.sh';
    local altPath="$2";
	
	util.load.file "$libraryName" "$altPath";

	return $?;
}

# loading a library
function util.load.config(){
    local libraryName="$1"'.cfg';
    local altPath="$2";
	
	util.load.file "$libraryName" "$altPath";	

	return $?;
}

# loading a library
function util.load.file(){
    local libraryName="$1";
    local altPath="$2";
    local librayPath;

	# try the alt path passed in params
	if [ "$altPath" != "" ] ; then
		librayPath="$altPath/$libraryName";

		if [ -f "$librayPath" ]; then
			. "$librayPath"
			return $?;
		else
			# Test if the log.error.out is loaded
			type log.error.out > /dev/null 2> /dev/null;

			if [ "$?" == "0" ] ; then 
				log.error.out library $libraryName not found in alternative path [$altPath].
			else
				echo ERROR - library $libraryName not found in alternative path [$altPath].
			fi
			return 1;
		fi
	fi

	# Try the default paths
    if [ "$LIB_PATH" != "" ] ; then
		librayPath="$LIB_PATH/$libraryName";

		if [ -f "$librayPath" ]; then
			. "$librayPath"
			return $?;
		fi
	fi

    librayPath="$BSU_PATH/$libraryName";

    if [ -f "$librayPath" ]; then
		. "$librayPath"
		return $?;
	else
		# Test if the log.error.out is loaded
		type log.error.out > /dev/null 2> /dev/null;

		if [ "$?" == "0" ] ; then 
			log.error.out library $libraryName not found neither BSU_PATH[$BSU_PATH] nor  LIB_PATH[$LIB_PATH].
		else
			echo ERROR - library $libraryName not found neither BSU_PATH[$BSU_PATH] nor  LIB_PATH[$LIB_PATH].
		fi

		return 1;
	fi	
}

# laoding main libraries
util.load.config configuration;

util.load.library error;
util.load.library log;

util.load.library batch;
util.load.library file;
