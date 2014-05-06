#!/bin/bash
#
# $HeadURL: $
# $Id$
#
# File utils
#

#
# returns true if arg2 is into de subtree of arg1
function file.isInSubtree(){
	local root="$1";
	local child="$2";
	
 	if [ -f $child ]; then 
		child=$(file.dirname $child);
	elif  [ ! -d $child ]; then 
#		echo "1";
		return 1;
 	fi

	cd "$child";
	child=`pwd`;
	cd -  > /dev/null;

	if [[ $child == "$root"* ]] ; then
#		echo "0";
		return 0;
	else
#		echo "1";
		return 1;
	fi
}

# /path/file.ext return /path
function file.dirname(){
	local dirname="$(dirname "$1")";

	echo $dirname;
}

# /path/file.ext return file.ext
function file.basename(){
	local baseName="$(basename "$1")";

	echo $baseName;
}

# /path/file.ext return ext
function file.ext(){
	local FILE="$1";

	echo "${FILE##*.}";
}

# /path/file.ext return /path/file
function file.name(){
	local FILE="$1";

	echo "${FILE%.*}";
}

# /path/file.ext return ext
function file.hasExtension(){
	local FILE="$1";
	local EXT="$2";
	local realExt="$(file.ext $FILE)";

	if [ "$EXT" == ".""$realExt" ] || [ "$realExt" == "$EXT" ] ; then
		return $EXIT_STATE_OK;		
	else
		return $EXIT_STATE_ERROR;
	fi
}

# /path/file.ext return /path
function file.size.2(){
	local file="$1";
#	local ret=`du -sk $file`;
	local message;
	local code;

	message=$(batch.exec du -sk $file);
	code=$?;

	if error.isOk $code; then
		set $message;
		echo $1;
 		return $TRUE;
	else
 		echo "-";
 		return $FALSE;
 	fi 
}

function file.size(){
	local file="$1";
	local message;
	local code;

	message=$(batch.exec wc $file);
	code=$?;

	if error.isOk $code; then
		set $message;
		echo $3;
 		return $TRUE;
	else
 		echo "-";
 		return $FALSE;
 	fi 
}


# File size in human readable 
function file.size.human(){
	local file="$1";
	local message;
	local code;

	message=$(batch.exec du -sh $file);
	code=$?;

	if error.isOk $code; then
		set $message;
		echo $1;
 		return $TRUE;
	else
 		echo "-";
 		return $FALSE;
 	fi 
}

# For the dir passed in parameter, iteates over all the files
# and dirs that are not hiden 
# and call the function, the second parameter.
# If the directory is empty the funcion is not called.
# This return $TRUE if the iteration reach the end and only returns
# false if one of the function call returns false. If a function call return 
# false the loop will end inmediatly.
#
function file.dir.iterate(){
	local dir="$1";
	local function="$2";

	if [ ! -d "$dir" ] ; then
		log.exception The dir:\"$dir\" does not exists.
	else
#		cd $dir;
		pushd $dir  > /dev/null;
		local file;
		for file in * ; do
			if [[ "$file" == "*" ]] ; then
				log.debug The directory:\"$dir\" is empty.
				break;
			else
#				log.debug "file.dir.iterate on file:\"$file\",pwd:"`pwd`;

# 				local ret="$($function $file)";
# 				if [ "$ret" != "" ] ;then 
# 					echo $ret;
# 				fi
#				echo -e $($function $file)
#				$function $file >> $LOG_OUT_FILE 2>> $LOG_ERROR_FILE
#				./sendToPublish.sh 
				if ! $function "$file" ; then 
					return $FALSE;
				fi				
			fi
		done
		
#		cd -  > /dev/null;
		popd > /dev/null;
	fi;

	return $TRUE;
}

# For the dir passed in parameter, iteates only over
# the dirs included into the parent dir
# and call the function, the second parameter.
# If the directory is empty the funcion is not called.
function file.dir.dirs.iterate(){
	local dir="$1";
	local function="$2";

	if [ ! -d "$dir" ] ; then
		log.error The dir:\"$dir\" does not exists.
	else
		pushd $dir > /dev/null;
		local file;

		for file in * ; do
			if [[ "$file" == "*" ]] ; then
				log.debug The directory:\"$dir\" is empty.
				break;
			elif [ -d "$file" ] ; then
#				log.debug "file.dir.dirs.iterate on file:\"$file\",pwd:"`pwd`;
#				echo $( $function $file);
#				echo -e $($function $file);
#				$function $file >> $LOG_OUT_FILE 2>> $LOG_ERROR_FILE
#				./sendToPublish.sh 
				$function $file
			fi
		done
		
#		cd -  > /dev/null;
		popd > /dev/null;
	fi;
}

function replace.white.spaces.iterator(){
	local file="$1"

	file.move.changeFileWihiteEspaces "$file";

	return $?;
}

function file.move.changeFileWihiteEspaces(){
	local file="$1"
	
	log.debug file:\"$file\";

	local replcedName=${file// /_};
	replcedName=${replcedName//\'/_};
	replcedName=${replcedName//\[/_};
	replcedName=${replcedName//\]/_};

	replcedName=${replcedName//\(/_};
	replcedName=${replcedName//\)/_};
	replcedName=${replcedName//\&/_};

	
	if [ "$file" != "$replcedName" ] ; then 
		mv "$file" "$replcedName";
		
		if [ $? ] ; then 
			log.info Moved file from:\"$file\" to \"$replcedName\";
		else
			log.error Movin file from:\"$file\" to \"$replcedName\";
		fi
	fi

	return $EXIT_STATE_OK;
}

function file.dir.changeFileWihiteEspaces(){
	local dir="$1"
	
	file.dir.iterate "$dir" replace.white.spaces.iterator

	return $?;
}

function file.dir.verifyCreate(){
	local dir="$1"
	
	if [ -d "$dir" ] ; then
		return $TRUE;
	else
		if batch.exec mkdir $dir ; then
			return $TRUE;
		else
			log.error The dir:$dir can not be create and do not exists.;
			return $FALSE;
		fi
	fi
}


#
# Lock directories stuff
#

LOCK_FILE_NAME="lock.dat";

function file.dir.lock.info(){
	echo "$SCRIPT_NAME":pid:"$$":$*;
}

function file.dir.isLocked(){
	local dir="$1";

	if [ ! -d "$dir" ] ; then	
		log.error The folder to lock is not a directory $dir;
		return $FALSE;
	else
		local lockFile=$dir/$LOCK_FILE_NAME;
		
		if [  -f "$lockFile" ] ; then	
			return $TRUE;
		else
			return $FALSE;
		fi
	fi

}

function file.dir.lock(){
	local dir="$1";
	local lockInfo="$2";

	if [ ! -d "$dir" ] ; then	
		log.error The folder to lock is not a directory $dir;
		return $FALSE;
	else
		local lockFile=$dir/$LOCK_FILE_NAME;
		
		if [ "$lockInfo" == "" ] ; then
			lockInfo=$(file.dir.lock.info);
		fi
		
		log.debug $lockInfo;

		if [  -f "$lockFile" ] ; then	
			log.error Already locked $dir ["$lockFile"];
			return $FALSE;
		else
			log.debug writing "$lockInfo" into $lockFile;
			echo "$lockInfo" > $lockFile;
			
			if error.isOk $? ; then
				if [  -f "$lockFile" ] ; then	
					log.debug Dir $dir LOCKED;
					return $TRUE;
				else
					log.error Strange error the lock file $lockFile has not be created.;
					return $FALSE;
				fi
			else
				log.error Error creating file $lockFile, info: $lockInfo ;
				return $FALSE;
			fi
		fi
	fi
}

function file.dir.unlock(){
	local dir="$1";
	local lockInfo="$2";

	if [ ! -d "$dir" ] ; then	
		log.error The folder to un-lock is not a directory $dir;
		return $FALSE;
	else
		local lockFile=$dir/$LOCK_FILE_NAME;
		
		log.debug lockFile:$lockFile;

		if [  -f "$lockFile" ] ; then	
			if [ "$lockInfo" != "" ] ; then
				# testing if the look info is the same
				local currentInfo=`cat $lockFile`;

				if [ "$currentInfo" != "$lockInfo" ] ; then
					log.warn For dir: $dir, the current lock info:$currentInfo is not the same as the passed $lockInfo;
					return $FALSE;
				fi
			fi

			if batch.exec rm $lockFile ; then 
				log.debug Dir unlocked: $dir;
				return $TRUE;
			else
				log.error Dir dir: $dir, can not be unlocked because file:$lockFile can not be removed;				
				return $FALSE;				
			fi
		else
			log.warn The dir $dir was not locked ...;
			return $TRUE;
		fi
	fi
}


# http://stackoverflow.com/questions/965053/extract-filename-and-extension-in-bash

# ~% FILE="example.tar.gz"
# ~% echo "${FILE%%.*}"
# example
# ~% echo "${FILE%.*}"
# example.tar
# ~% echo "${FILE#*.}"
# tar.gz
# ~% echo "${FILE##*.}"
# gz