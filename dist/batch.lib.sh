#!/bin/bash
#
# $HeadURL: $
# $Id$
#
# Batch utils.
#

SSH_TIMEOUT=5;

function batch.started(){

	if [ "$1" == "-h" ] || [ "$1" == "-?"  ] || [ "$1" == "--help"  ] || [ "$1" == "-help" ] ; then

		batch.usage $*;
		exit $EXIT_STATE_OK;
	else
		log.info "---- ---- ---- ---- ---- ---- ---- ----";
		log.info $SCRIPT_NAME Started ....
	fi
}

function batch.usage(){
	local baseName="$(basename "$0")";

	echo -e "\n"$baseName"\n";
	if [ "$USAGE" == "" ] ; then 
		echo -e "Usage of command not defined.";
	else
		echo -e "Usage: "$USAGE;
	fi
	return $EXIT_STATE_OK;
}

function batch.exec(){
	local code;
	log.debug Executing \""$*\" ...";
	$*  2>> $LOG_ERROR_FILE
	code=$?;
	
	if [ $code == $EXIT_STATE_OK ] ; then
		return $TRUE;
	else
		log.debug Error while executin command:\"$*\", code:$code;
		return $code;
	fi
}

function batch.exec.bg(){
	local code;
	log.debug Executiing in background \""$*\" ...";
	$*  2>> $LOG_ERROR_FILE &
	code=$?;
	
	if [ $code == $EXIT_STATE_OK ] ; then
		log.debug Executiing \""$*\" DONE.";
		return $TRUE;
	else
		log.exception Command:\"$*\";
		return $FALSE;
	fi
}

function batch.exitOK(){
	log.info $SCRIPT_NAME Finish ok.
	exit $EXIT_STATE_OK;
}

function batch.exitError(){
	log.error $SCRIPT_NAME Finish Error: $*
	echo $SCRIPT_NAME Finish Error: $*
	exit  $EXIT_STATE_ERROR;
}

function batch.exitOnError(){
	if error.isError $? ; then
		log.error $SCRIPT_NAME Finish Error: $*
		echo $SCRIPT_NAME Finish Error: $*
		exit  $EXIT_STATE_ERROR;
	fi
}


function batch.execute.remote.script(){
	local server="$1";
	local repo="$2";
	local cmd="$3";
	
	local chaine="ssh $server $repo/scripts/$cmd";

#	log.debug Ejecutando: $chaine;
# http://unix.stackexchange.com/questions/27218/is-it-possible-to-get-the-error-message-from-previous-command-which-failed-when


	local code;
	local message;
	message=`ssh -o ConnectTimeout=$SSH_TIMEOUT $server $repo/scripts/$cmd 2>&1`;
	code=$?;

	if error.code.exists $message ; then
		log.debug "Executed command :\"$chaine\" message:\"$message\" result:\"$code:\"".
		echo $message;
		return $message;
#		return $code;
	else
		if [ $code == $EXIT_STATE_OK ] ; then 
			log.debug Executed command:\"$chaine\"
			log.debug Message:\"$message\"
			log.debug Result:\"$code\"
			
			echo $message;
			return $code;
		else
			log.debug Error while executing command:\"$chaine\"
			log.debug Message:\"$message\"
			log.debug Result:\"$code\"

			echo $message;
			return $code;
		fi
	fi
}

function batch.execute.remote.command(){
	local server="$1";
	local cmd="$2";
	local code;
	local message;
	
	local chaine="ssh $server $cmd";


	message=`ssh -o ConnectTimeout=$SSH_TIMEOUT $server $cmd 2>&1`;
	code=$?;

	if [ $code == $EXIT_STATE_OK ] ; then  
		log.debug Executed command:\"$chaine\", Message:\"$message\",Result:\"$code\"
	else
		log.exception.out Executed command:\"$chaine\", Message:\"$message\",Result:\"$code\"
	fi

	return $code;
}



_BACKUP_NAME="back.";

function batch.backup.iterator(){
	local newDir="$1";
	local file="$2";

#	log.debug RET2:\"$file\";
	if [ ! -d $file ];then 
		log.debug Moviendo el fichero $file;
		batch.exec mv $file $newDir;
	fi
}

function batch.backup.dir.create(){
	local dir="$1";
	
	if [ ! -d $dir ] ; then
		log.exception "The specified directory is not a directory or it does not exists. dir:$dir".
		return $EXIT_STATE_ERROR;
	else
		local stringDate=`date +%y%m%d%H%M%S`
		local newDir=$_BACKUP_NAME$stringDate;

		cd "$dir";
		mkdir $newDir;
		local ret=$?;
		cd -  > /dev/null;

		if [ $? == $EXIT_STATE_OK ] ; then 
			# movemos todos los ficheros al nuevo directorio
			cd "$dir";

			file.dir.iterate . "batch.backup.iterator $newDir";
			
			cd -  > /dev/null;			

			echo $newDir;
			return $EXIT_STATE_OK;
		else
			log.exception "The $newDir, hasent been created" ;
			return $EXIT_STATE_ERROR;
		fi
	fi
}

# We use this function to copy the conten of two directories.
# To be more effetive we use the sync command
function batch.sync.dirs(){
	local sourceDir="$1";
	local targetDir="$2";
	

	if [ -d "$sourceDir" ] ; then
		pushd "$sourceDir" >  /dev/null;
				
		batch.exec rsync --verbose --compress --recursive --relative \
			--times --perms --links --delete --rsh=ssh \
			--exclude=*bak --exclude=*~ --exclude=.svn/\
			.  "$targetDir" \
			>> $LOG_OUT_FILE 2>> $LOG_ERROR_FILE
		
		
		popd > /dev/null;
		return $EXIT_STATE_OK;
	else
		log.exception The path to sync \"$sourceDir\" do not exists.
		return $EXIT_STATE_ERROR;
	fi
}