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
	
 	if [ -f "$child" ]; then 
		child="$(file.dirname $child)";
	elif  [ ! -d "$child" ]; then 
		return $FALSE;
 	fi

	pushd "$child"  > /dev/null;
	child=`pwd`;
	popd > /dev/null;
	

	if [[ $child == "$root"* ]] ; then
		return $TRUE;
	else
		return $FALSE;
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

	if [[ "$FILE" == *"$EXT" ]] ; then
		return $TRUE;		
	else
		return $FALSE;
	fi

# 	local realExt="$(file.ext $FILE)";
#
# 	log.info.out [$realExt] [$FILE] [$EXT];
#
# 	if [ "$EXT" == ".""$realExt" ] || [ "$realExt" == "$EXT" ] ; then
# 		return $TRUE;		
# 	else
# 		return $FALSE;
# 	fi
}

# /path/file.ext return /path
function file.size.2(){
	local file="$1";
#	local ret=`du -sk $file`;
	local message;
	local code;

	message=$(batch.exec.get.out du -sk "$file");
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
	local error="-";

	if [ ! -e "$file" ] ; then
		echo "$error";
		return $FALSE;
	fi

	local message;
 	local code;

	message=`stat --printf="%s\n" "$file"`;
# 	message=$(batch.exec.get.out wc -c "$file");
 	code=$?;

 	if error.isOk $code; then
 		set $message;
 		echo $1;
  		return $TRUE;
 	else
		message=`stat -f "%z" "$file"`;
 		code=$?;
 		if error.isOk $code; then
 			set $message;
 			echo $1;
  			return $TRUE;
		else
  			echo "$error";
  			return $FALSE;
		fi
  	fi 
}


# File size in human readable 
function file.size.human(){
	local file="$1";
	local message;
	local code;

	message=$(batch.exec.get.out du -sh "$file");

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
		log.exception.out The dir:\"$dir\" does not exists.
	else
		pushd "$dir"  > /dev/null;
		local file;
		for file in * ; do
			if [[ "$file" == "*" ]] ; then
				log.debug The directory:\"$dir\" is empty.
				break;
			elif [[ "$file" == "$LOCK_FILE_NAME" ]] ; then
				log.debug Avoid $LOCK_FILE_NAME;
			else
				if ! $function "$file" ; then 
					popd > /dev/null;
					return $FALSE;
				fi				
			fi
		done
		
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
		log.exception The dir:\"$dir\" does not exists.
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

# For the dir passed in parameter, iteates only over
# the files included into the parent dir
# and call the function, the second parameter.
# If the directory is empty the funcion is not called.
function file.dir.files.iterate(){
	local dir="$1";
	local function="$2";

	if [ ! -d "$dir" ] ; then
		log.exception The dir:\"$dir\" does not exists.
	else
		pushd "$dir" > /dev/null;
		local file;

		for file in * ; do
			if [[ "$file" == "*" ]] ; then
				log.debug The directory:\"$dir\" is empty.
				break;
			elif [ -f "$file" ] ; then
				$function "$file"
			fi
		done
		
		popd > /dev/null;
	fi;
}


function replace.white.spaces.iterator(){
	local file="$1"

	file.move.changeFileWihiteEspaces "$file";

	# Do not stops iteration ....
	return $TRUE;
}

function file.move(){
	local orig="$1"
	local dest="$2"

	if [ ! -e "$orig" ] ; then
		log.exception.out The origin file does not exists [$orig].
		return $FALSE;
	fi

#	if [ ! -e "$dest" ] ; then
#		log.exception.out The destination file does not exists [$dest].
#		return $FALSE;
#	fi

	if ! batch.exec mv "$orig" "$dest" ; then
		log.exception.out While moving from $orig to $dest.
		return $FALSE;
	else
		log.debug moved $orig to $dest.
		return $TRUE;
	fi	
}


function file.move.changeFileWihiteEspaces(){
	local file="$1"
	
	log.debug file:\"$file\";

	local replcedName=${file// /-};

	replcedName=${replcedName//-/_};
	replcedName=${replcedName//\'/_};
	replcedName=${replcedName//\[/_};
	replcedName=${replcedName//\]/_};

	replcedName=${replcedName//\(/_};
	replcedName=${replcedName//\)/_};
	replcedName=${replcedName//\&/_};

#	file="$replcedName$extenxion";
	
	if [ "$file" != "$replcedName" ] ; then 
		mv "$file" "$replcedName";
		
		if [ $? ] ; then 
			log.info Moved file from:\"$file\" to \"$replcedName\";
			return $FALSE;
		else
			log.error Moving file from:\"$file\" to \"$replcedName\";
			return $TRUE;			
		fi
	fi
	return $TRUE;
}

function file.dir.changeFileWihiteEspaces(){
	local dir="$1"
	
	file.dir.iterate "$dir" replace.white.spaces.iterator

	return $?;
}

function file.dir.files.changeFileWihiteEspaces(){
	local dir="$1"
	
	file.dir.files.iterate  "$dir" replace.white.spaces.iterator

	return $?;
}

function file.dir.verifyCreate(){
	local dir="$1"
	
	if [ -d "$dir" ] ; then
		return $TRUE;
	else
		if batch.exec mkdir "$dir" ; then
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
		local lockFile="$dir/$LOCK_FILE_NAME";
		
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
		log.exception The folder to lock is not a directory $dir;
		return $FALSE;
	else
		local lockFile="$dir/$LOCK_FILE_NAME";
		
		if [ "$lockInfo" == "" ] ; then
			lockInfo=$(file.dir.lock.info);
		fi
		
		log.debug $lockInfo;

		if [  -f "$lockFile" ] ; then	
			log.error Already locked $dir ["$lockFile"];
			return $FALSE;
		else
			log.debug writing "$lockInfo" into "$lockFile";
			echo "$lockInfo" > "$lockFile";
			
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
		log.exception The folder to un-lock is not a directory $dir;
		return $FALSE;
	else
		local lockFile="$dir/$LOCK_FILE_NAME";
		
		log.debug lockFile:$lockFile;

		if [  -f "$lockFile" ] ; then	
			if [ "$lockInfo" != "" ] ; then
				# testing if the look info is the same
				local currentInfo=`cat "$lockFile"`;

				if [ "$currentInfo" != "$lockInfo" ] ; then
					log.warn For dir: $dir, the current lock info:$currentInfo is not the same as the passed $lockInfo;
					return $FALSE;
				fi
			fi

#			if batch.exec rm "$lockFile" ; then 
			if  rm "$lockFile" ; then 
				log.debug Dir unlocked: $dir;
				return $TRUE;
			else
				log.error Dir dir: $dir, can not be unlocked because file:[$lockFile] can not be removed;				
				return $FALSE;				
			fi
		else
			log.warn The dir $dir was not locked ...;
			return $TRUE;
		fi
	fi
}


function file.rm.file(){
	local file="$1";

	if [ ! -e  "$file" ] ; then
		log.error.out The file [$file] does not exits ...
		return $TRUE;
	else
		local code;
		
		rm "$file";

		code=$?;

		if [ -e  "$file" ] ; then
			log.error.out The file [$file] can not be deleted code[$code];
			return $FALSE;
		else
			log.info.out File [$file] deleted. code[$code];
			return $TRUE;
		fi
	fi
}

function file.list(){
	local path="$1";
	local filter="$2";
	local separator="$3";

	local files="";

	pushd $path > /dev/null;

	for f in $filter; do
#		log.error.out F:"$files", P:"$path", f:"$f";

		if [ "$f" == "$filter" ] ; then 
			echo $files
			return $TRUE;
		elif [ "$files" == "" ] ; then 
			files="$f";		
		else
			files="$files":"$f";		
		fi
	done

	popd  > /dev/null;

	echo $files

	return $TRUE;
}

function file.symlink.create(){
	local originalFile="$1";
	local targetFile="$2";
	
	if ! batch.exec ln -s "$originalFile" "$targetFile" ; then
		log.exception Error making a symbolick link from:[$originalFile], to:[$outputFilePath];
		return $FALSE;
	else
		log.info Symbolig link created from:[$originalFile], to:[$outputFilePath];
		return $TRUE;
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