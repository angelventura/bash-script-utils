#!/bin/bash
#
# $HeadURL: $
# $Id$
#
# Eror lib
#


# Global constants 
# Return statate of the BASH processes
EXIT_STATE_OK=0
EXIT_STATE_STANDARD_ERROR=1

# Global constants
TRUE=0
FALSE=1


# This display the label associated to the error code
function error.code.display(){
	local code="$1"

	if [ "$code" == $EXIT_STATE_OK ] ||  [ "$code" == $TRUE ] ; then
		echo "True/return OK";
	elif [ "$code" == $FALSE ] ; then
		echo "False/return Error";
	else
		echo "Error code \"$code\".";
	fi
}

# Tells if the error code is the standard one or a spetial one
# EXIT_STATE_OK and EXIT_STATE_STANDARD_ERROR returns TRUE otherwise returns false.
function error.code.exists(){
	local code="$1"

	if  [ "$code" == $FALSE ] ; then
		return $TRUE;
	elif [ "$code" == $EXIT_STATE_OK ] ||  [ "$code" == $TRUE ] ; then
		return $TRUE;
	else
		return $FALSE;
	fi
}


# This transform from the restun process states to TRUE/FALSE.
# 
function error.isError(){
	if [ "$1" != $EXIT_STATE_OK ] ; then 
		return $TRUE;
	else
		return $FALSE;
	fi
}

function error.isOk(){
	if [ "$1" == $EXIT_STATE_OK ] ; then 
		return $TRUE;
	else
		return $FALSE;
	fi
}

function error.isTrue(){
	local arg="$1"

	if [ "$arg" == "" ] ; then
		return $FALSE;
	elif  [ "$arg" == "true" ] ; then
		return $TRUE;
	elif  [ "$arg" == "0" ] ; then
		return $TRUE;
	elif  [ "$arg" == "TRUE" ] ; then
		return $TRUE;
	else
		return $FALSE;
	fi
}

