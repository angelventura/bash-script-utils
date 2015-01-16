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

	message=$(batch.exec ps $pid);
	
	ret=$?;

	return $ret;
}

function system.pid(){
	echo $$;
	return $TRUE;
}

# true is the url is running
function system.http.isRunning(){	
	local url="$1";
	local message;
	local ret;

	if batch.exec "$CURL_CMD $url" 1>/dev/null ; then 
		return $TRUE;
	else
		log.exception "$CURL_CMD $url";
		return $FALSE;
	fi
}
