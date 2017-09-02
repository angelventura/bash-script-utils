#!/bin/bash
#
# $HeadURL: http://svn/svn/estrada-gconf/scripts/utils/utils.sh $
# $Id$
#
# Sistema utilities
#

# Test for several includes
if [ "$__SYSTEM_LIB_SH" != "" ] ; then
	log.debug Aditional include __SYSTEM_LIB_SH[$__SYSTEM_LIB_SH];
	return $TRUE;
else
	__SYSTEM_LIB_SH="__SYSTEM_LIB_SH";
	log.debug first include __SYSTEM_LIB_SH[$__SYSTEM_LIB_SH];
fi

function system.proceses.exists(){
	local pid="$1";
	local message;
	local ret;

#	message=$(batch.exec ps $pid);
#	
#	ret=$?;
#
#	return $ret;

	# The ps command will hide the root process to the normal users.
	# This is necesary to tne v_nginx process executed as root to know if the 
	# process ares working
	if [ -e /proc/$pid ] ; then
		return $TRUE;
	else
		return $FALSE;
	fi

# 	local PROCESS="$1";
# 	PIDS=`ps cax | grep $PROCESS | grep -o '^[ ]*[0-9]*'`
# 	if [ -z "$PIDS" ]; then
# 		# echo "Process not running." 1>&2
# 		return $FALSE;
# 	else
# #		for PID in $PIDS; do
# #			echo $PID
# #		done
# 		return $TRUE;
# 	fi
}

function system.pid(){
	echo $$;
	return $TRUE;
}

# true is the url is running
function system.http.isRunning(){	
	local url="$1";
	local userAgent="$2";
	local message;
	local ret;

	if [ "$userAgent" == "" ] ; then
		userAgent="BSU TESTS user agent";
	fi
	
	if batch.exec "$CURL_CMD" -A "$userAgent" "$url" 1>/dev/null ; then 
		return $TRUE;
	else
		log.exception "$CURL_CMD" "$url";
		return $FALSE;
	fi
}
