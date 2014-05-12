#!/bin/bash
#
# Utilities for Arrays and Hasn maps
#

function array.add(){
	local name="$1";
	local value="$2";

	if [ -v $name ] ; then
		eval "$name+=( $value );";
	else
		eval "declare -ga $name=( $value );";
	fi

	return $TRUE;
#
#	echo $name;
}

function array.create(){
	local name="$1";

	if [ -v $name ] ; then
		log.error While creating an already existing array:$name. $*;
	else
		eval "declare -ga $name;";
	fi

	return $TRUE;
}

function array.create.value(){
	local name="$1";
	local separator="$2";
	local values="$3";

	array.create $name;

	IFS="$separator" read -a "$name" <<< "$values";

	return $TRUE;
}

function array.exists(){
	local name="$1";

	if [ -v $name ] ; then
		return $TRUE;
	else
		return $FALSE;
	fi
}

function array.iterate(){
	local name="$1";
	local function="$2";

	if [ ! -v $name ] ; then
		log.exception The array \"$name\" is nor defined. $*;
	else
		local array="${name}[@]"
		for item in "${!array}"; do
			log.debug Iterate over $item;
			if ! $function "$item" ; then 
				log.debug Array iteration stoped by client function on item $item;
				return $FALSE;
			fi				
		done		
	fi		
	return $TRUE;
}

function hash.exists(){
	array.exists $*;

	return $?;
}

function hash.add(){
	local name="$1";
	local key="$2";
	local value="$3";

	if ! hash.exists $name ; then
		eval "declare -gA $name;";
	fi

	eval "$name[$key]=$value;";

	return $TRUE;
#	echo $variable;
}

function hash.create(){
	local name="$1";
	
	if ! hash.exists $name ; then
		eval "declare -gA $name;";
	fi
}

function hash.key.exist(){
	local name="$1";
	local key="$2";

	if ! hash.exists $name ; then
		log.exception The hash $name is nor defined. $*.
		return $FALSE;
	else
		if eval "test \${$name[$key]+_} " ; then
			return $TRUE;
		else
			return $FALSE;
		fi
	fi
}

function hash.get(){
	local name="$1";
	local key="$2";

	local value="";

	eval "value=\${$name[$key]}";

	echo $value;
}

function hash.iterate.keys(){
	local name="$1";
	local function="$2";

	if ! hash.exists $name ; then
		log.exception The hash $name is nor defined. $*;
	else
#http://bash.cumulonim.biz/FullBashFAQ.html
#http://stackoverflow.com/questions/11776468/create-associative-array-in-bash-3
#http://beggytech.blogspot.be/2010/02/bash-associative-arrays.html

		local array;
		eval array=\( \${!${name}[@]} \);
		for i in "${!array[@]}" ; do
			local key=${array[${i}]};
#  			log.info.out Iterate over $key;
  			if ! $function "$key" ; then 
  				log.debug Array iteration stoped by client function on key $key;
  				return $FALSE;
  			fi				
		done
	fi		
	return $TRUE;
}

function hash.iterate.values(){
	local name="$1";
	local function="$2";

	if ! hash.exists $name ; then
		log.exception The hash $name is nor defined. $*;
	else
 		local array="${name}[@]"
 		for item in "${!array}"; do
 			log.debug Iterate over $item;
 			if ! $function "$item" ; then 
 				log.debug Array iteration stoped by client function on item $item;
 				return $FALSE;
 			fi				
 		done		
	fi		
	return $TRUE;
}


#
# http://stackoverflow.com/questions/13305717/bash-scripting-iterating-through-variable-variable-names-for-a-list-of-assoc
#
function hash.iterate(){
	local name="$1";
	local function="$2";

	if ! hash.exists $name ; then
		log.exception The hash $name is nor defined. $*;
	else
		local keyref="${name}[@]";

		for key in $(eval echo '${!'$keyref'}'); do
			valref="${name}[$key]"
#			echo "key = $key"
#			echo "value = ${!valref}"

 			if ! $function "$key" "${!valref}"; then 
  				log.debug Array iteration stoped by client function on item $item;
  				return $FALSE;
  			fi				

		done
	fi		
	return $TRUE;
}
