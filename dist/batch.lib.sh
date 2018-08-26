#!/bin/bash
#
# $HeadURL: $
# $Id$
#
# Batch utils.
#

# Test for several includes
if [ "$__BATCH_LIB_SH" != "" ] ; then
	log.debug Aditional include __BATCH_LIB_SH[$__BATCH_LIB_SH];
	return $TRUE;
else
	__BATCH_LIB_SH="__BATCH_LIB_SH";
	log.debug first include __BATCH_LIB_SH[$__BATCH_LIB_SH];
fi

SSH_TIMEOUT=5;
BATCH_HEADLESS="$FALSE";

BATCH_HEADLESS_ARG="-headless";
BATCH_EXCLUSIVE_ARG="-exclusive";

BATCH_REMOTE_LOG_ARG="-remoteLog";


BATCH_SCRIPT_START_DATE=`date "$DATE_FORMAT"`;
BATCH_SCRIPT_START_TIME_IN_SECONS=$(date +"%s")

function batch.started(){

	if [ "$1" == "-h" ] || [ "$1" == "-?"  ] || [ "$1" == "--help"  ] || [ "$1" == "-help" ] ; then

		batch.usage $*;
		exit $TRUE;
	else
		local DATE=`date +"%Y-%m-%d_%H-%M"`;

		if [ "$1" == "-v" ] || [ "$1" == "-verbose"  ] || [ "$1" == "--verbose"  ]  ; then

			#		log.info.out LOG_LEVEL: $LOG_LEVEL;
			#		log.info.out LOG_ERROR_FILE: $LOG_ERROR_FILE;
			#		log.info.out LOG_OUT_FILE: $LOG_OUT_FILE;

			LOG_ERROR_FILE="/dev/stderr";
			LOG_OUT_FILE="/dev/stdout";

			LOG_LEVEL="DEBUG"
			
		else
 			LOG_ERROR_FILE="$LOG_PATH/$SCRIPT_NAME-error-$DATE-$$.log";
 			LOG_OUT_FILE="$LOG_PATH/$SCRIPT_NAME-info-$DATE-$$.log";

		fi
			
			SCRIPT_PID_FILE="$PID_PATH/$SCRIPT_NAME-$$.pid";
			LOG_PID_FILE="$PID_PATH/$SCRIPT_NAME-pid-$$.log";
			

		if [[ $@ == *"$BATCH_HEADLESS_ARG"* ]] ; then
			BATCH_HEADLESS="$TRUE";
		else
			BATCH_HEADLESS="$FALSE";
		fi

		if [[ $@ == *"$BATCH_REMOTE_LOG_ARG"* ]] ; then
			REMOTE_LOG=$TRUE;
			REMOTE_LOG_HOST_NAME=`hostname`;
		else
			REMOTE_LOG=$FALSE;
		fi


		# Before creating all the files in $PID_PATH/
		if [[ $@ == *"$BATCH_EXCLUSIVE_ARG"* ]] ; then
			local files=`ls $PID_PATH/$SCRIPT_NAME* 2> /dev/null`;

			if [  "$files" != "" ] ; then
				batch.exitError "EXCLUSIVE mode. Another process [$SCRIPT_NAME] is running, check the path:[$PID_PATH]"				
			fi
		fi



# 		echo " ";
#  		echo "---- ---- ---- ---- ---- ---- ---- ----";
#  		echo " $BATCH_SCRIPT_START_DATE - Started : [$$] $SCRIPT_NAME $* ";
#  		echo "   ";
#  		echo " Log level $LOG_LEVEL ";
#  		echo " Setting stdout log to $LOG_OUT_FILE ";
#  		echo " Setting stderr log to $LOG_ERROR_FILE";
#  		echo "---- ---- ---- ---- ---- ---- ---- ----";
# 		echo " ";

		local msg="---- ---- ---- ---- ---- ---- ---- ----\n\
 - Date : $BATCH_SCRIPT_START_DATE \n\
 - Started : [$$] $SCRIPT_NAME $* \n\
 - Log level $LOG_LEVEL \n\
 - Setting stdout log to $LOG_OUT_FILE \n\
 - Setting stderr log to $LOG_ERROR_FILE \n\
---- ---- ---- ---- ---- ---- ---- ----\n\
";

		if [ "$BATCH_HEADLESS" != "$TRUE" ] ; then
			echo -e "$msg"
		fi
		echo -e "$msg" > "$SCRIPT_PID_FILE"
		echo -e "$msg" > "$LOG_ERROR_FILE"
		echo -e "$msg" > "$LOG_OUT_FILE"
		echo -e "$msg" > "$LOG_PID_FILE"

	fi
}

function batch.exitOK(){
	local msg="\n\
---- ---- ---- ---- ---- ---- ---- ----\n\
 Finish OK: [$$] $SCRIPT_NAME $* Finish OK.\n\
\n\
[ Started: $BATCH_SCRIPT_START_DATE, laps: $(batch.display.Laps.from.start)]\n\
---- ---- ---- ---- ---- ---- ---- ----";
	
	if [ "$BATCH_HEADLESS" != "$TRUE" ] ; then
		echo -e "$msg"
	fi

	echo -e "$msg" >> "$SCRIPT_PID_FILE"
	echo -e "$msg" >> "$LOG_ERROR_FILE"
	echo -e "$msg" >> "$LOG_OUT_FILE"
	echo -e "$msg" >> "$LOG_PID_FILE"
	
	if [ -e "$SCRIPT_PID_FILE" ] ; then
#		mv "$SCRIPT_PID_FILE" "$LOG_PATH"; 
		rm "$SCRIPT_PID_FILE"; 
	fi

	if [ -e "$LOG_PID_FILE" ] ; then
#		mv "$LOG_PID_FILE" "$LOG_PATH"; 
		rm "$LOG_PID_FILE" ; 
	fi

    # Remove the logs If they are files
	if [ -f "$LOG_ERROR_FILE" ] ; then
		rm "$LOG_ERROR_FILE"
	fi

	if [ -f "$LOG_OUT_FILE" ] ; then
		rm "$LOG_OUT_FILE"
	fi


	exit $TRUE;
}

function batch.exitError(){
	log.error.out $SCRIPT_NAME Finish Error: $*

	local msg="\n\
---- ---- ---- ---- ---- ---- ---- ----\n\
 [$$] $SCRIPT_NAME \n\
\n\
 Lap : $(batch.display.Laps.from.start)\n\
 Star: $BATCH_SCRIPT_START_DATE\n\
 End :    `date "$DATE_FORMAT"`\n\
\n\
 FINISH ON ERROR: [$*]\n\
---- ---- ---- ---- ---- ---- ---- ----"; 

#	log.error.out "$msg";
	if [ "$BATCH_HEADLESS" != "$TRUE" ] ; then
		echo -e "$msg"
	fi
	echo -e "$msg" >> "$LOG_ERROR_FILE"
	echo -e "$msg" >> "$LOG_OUT_FILE"

	if [ -e "$SCRIPT_PID_FILE" ] ; then
		echo -e "$msg" >> "$SCRIPT_PID_FILE"
		mv "$SCRIPT_PID_FILE" "$LOG_PATH"; 
	fi

	if [ -e "$LOG_PID_FILE" ] ; then
		echo -e "$msg" >> "$LOG_PID_FILE"
		mv "$LOG_PID_FILE" "$LOG_PATH"; 
	fi


	exit  $FALSE;
}

function batch.usage(){
	local baseName="$(basename "$0")";

	echo -e "\n"$baseName"\n";
	if [ "$USAGE" == "" ] ; then 
		echo -e "Usage of command not defined.";
	else
		echo -e "Usage: "$USAGE;
	fi

	echo -e $BATCH_EXCLUSIVE_ARG: Exclusive mode if another command is running this will exit;
	echo -e $BATCH_HEADLESS_ARG: No process information will be written in the stdout;

	return $TRUE;
}

function batch.exec(){
	local code;
	local scaped_args;

	for var in "$@" ; do
		scaped_args="$scaped_args"" ""\"$var\""
	done
	
	log.info Executing [$scaped_args] ...;
	
	eval $scaped_args  >> $LOG_OUT_FILE 2>> $LOG_ERROR_FILE

	code=$?;

	if [ $code == $TRUE ] ; then
		return $TRUE;
	else
		log.exception Error while executin command: $scaped_args, code:$code;
		return $code;
	fi
}

function batch.exec.noescape(){
	
	log.info ++++++++COMMAND: $* ;
	
	$*  >> $LOG_OUT_FILE 2>> $LOG_ERROR_FILE
	
	code=$?;

	if [ $code == $TRUE ] ; then
		return $TRUE;
	else
		log.exception Error while executin command: $*, code:$code;
		return $code;
	fi
}

# the same as batch.exec bu the stdout is not redirected
# to the log file
function batch.exec.get.out(){
	local code;
	local scaped_args;
	
	for var in "$@" ; do
		scaped_args="$scaped_args"" ""\"$var\""
	done


#	log.debug Executing \""$*\" ...";
	log.debug Executing [$scaped_args] ...;

	# This is the only dif with batch.exec
	eval $scaped_args  2>> $LOG_ERROR_FILE
	code=$?;
	
	if [ $code == $TRUE ] ; then
		return $TRUE;
	else
		log.exception Error while executin command: $scaped_args, code:$code;
		return $code;
	fi
}

function batch.exec.bg(){
	local code;

	local scaped_args;
	for var in "$@" ; do
		scaped_args="$scaped_args"" ""\"$var\""
	done

	log.debug Executing in background [$scaped_args] ...;

#	$*  2>> $LOG_ERROR_FILE &
	eval $scaped_args  2>> $LOG_ERROR_FILE &
	code=$?;
	
	if [ $code == $TRUE ] ; then
		# log.debug Executiing \""$*\" DONE.";
		return $TRUE;
	else
		log.exception Error while executin command: $scaped_args, code:$code;
		return $FALSE;
	fi
}

function batch.display.Laps.from.start(){
	local laps=$(( $(date +"%s") - $BATCH_SCRIPT_START_TIME_IN_SECONS))

	echo $(displaytime $laps);
}

# http://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
function displaytime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%d d. ' $D
  [[ $H > 0 ]] && printf '%d h. ' $H
  [[ $M > 0 ]] && printf '%d min. ' $M
  [[ $D > 0 || $H > 0 || $M > 0 ]] && printf ' '
  printf '%d sec.\n' $S
}

function batch.exitOnError(){
	if error.isError $? ; then
		log.error $SCRIPT_NAME Finish Error: $*
		echo $SCRIPT_NAME Finish Error: $*
		exit  $FALSE;
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
#		return $message;
		return $code;
	else
		if [ $code == $TRUE ] ; then 
			log.debug Executed command:\"$chaine\"
			log.debug Message:\"$message\"
			log.debug Result:\"$code\"
			
			echo $message;
			return $code;
		else
			log.info Command return error code, command:\"$chaine\"
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

	if [ $code == $TRUE ] ; then  
		log.debug Executed command:\"$chaine\", Message:\"$message\",Result:\"$code\"
	else
		log.exception Executed command:\"$chaine\", Message:\"$message\",Result:\"$code\"
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
		batch.exec mv "$file" "$newDir";
	fi
}

function batch.backup.dir.create(){
	local dir="$1";
	
	if [ ! -d $dir ] ; then
		log.exception "The specified directory is not a directory or it does not exists. dir:$dir".
		return $FALSE;
	else
		local stringDate=`date +%y%m%d%H%M%S`
		local newDir=$_BACKUP_NAME$stringDate;

		cd "$dir";
		mkdir $newDir;
		local ret=$?;
		cd -  > /dev/null;

		if [ $? == $TRUE ] ; then 
			# movemos todos los ficheros al nuevo directorio
			cd "$dir";

			file.dir.iterate . "batch.backup.iterator $newDir";
			
			cd -  > /dev/null;			

			echo $newDir;
			return $TRUE;
		else
			log.exception "The $newDir, hasent been created" ;
			return $FALSE;
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
		return $TRUE;
	else
		log.exception The path to sync [$sourceDir] do not exists.
		return $FALSE;
	fi
}

# function batch.args.contains() {
# 	local arg="$1";
#
# #	if [[ $@ == *'-disableVenusBld'* ]]
# 	if [[ "$ARGS_ARGS" == *"$arg"* ]] ; then
# 		return $TRUE;
# 	else
# 		return $FALSE;
# 	fi
# }
