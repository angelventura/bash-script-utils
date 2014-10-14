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

#	log.exception.out $name;
#	log.info.out name[$name];

	if [ -v $name ] ; then
		log.warn Already existing array:$name. $*. Another object with the same name already exits.;
	else
		eval "declare -ga $name;";
	fi

	return $TRUE;
}

function array.create.value(){
	local name="$1";
	local separator="$2";
	local values="$3";

#	log.exception NAME: [$name];
#	log.info.out name:[$name];


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

function array.print(){
	local name="$1";
	local array="${name}[@]"

	local item;
	for item in "${!array}"; do
		log.info ITEM:[$item];
	done		

}

function array.iterate(){
	local name="$1";
	local function="$2";

	if [ ! -v $name ] ; then
		log.exception The array \"$name\" is nor defined. $*;
	else
		local array="${name}[@]"
		local item;
		for item in "${!array}"; do
#			log.info.out Iterate over [$item];
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

function hash.name(){
	local name="$1";
	
	echo ${name//[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ]/_};
#	echo ${name//[!a-zA-Z]/_};

	return $TRUE;
}

function hash.add(){
	local name="$1";
	local key="$2";
	local value="$3";

	if [ "$key" == "" ] ; then
		log.exception $name adding a empty key.
		return $FALSE;
	fi

	if ! hash.exists "$name" ; then
		eval "declare -gA $name;";
	fi

	eval "$name[\"$key\"]=\"$value\";";

	return $TRUE;
#	echo $variable;
}

function hash.create(){
	local name="$1";
	
	if ! hash.exists $name ; then
		eval "declare -gA $name;";
		log.debug Created hash: $name;
	fi

	if ! hash.exists $name ; then
		log.exception.out Fatal error creationg hash [$name];
		batch.exitError Fatal error creationg hash [$name];
	fi

	return $TRUE;
}

function hashset.values.exist(){
	local values="$1";
	local target="$2";
	local arrayName="hashset_tmp";

	array.create.value "$arrayName" "," "$values";

	local array="${arrayName}[@]"

	local item;
	for item in "${!array}"; do
		
		if [ "$target" == "$item" ] ; then
			return $TRUE;
		fi
	done		
	
	return $FALSE;
}

# This creates a hash set from a string separated by separatos
function hash.create.value(){
	local name="$1";
	local separator="$2";
	local values="$3";
	local arrayName="$1_tmp";

	array.create.value "$arrayName" "$separator" "$values";

	local array="${arrayName}[@]"

	hash.create "$name";

	local item;
	for item in "${!array}"; do
#		log.info.out ITEM:[$item];

		hash.add "$name" "$item" "$item";
	done		

#	array.create $arrayName;
#	IFS="$separator" read -a "$arrayName" <<< "$values";
# http://stackoverflow.com/questions/21692445/convert-an-indexed-array-into-an-associative-array-in-bash
#	declare -A "newArray=( $(echo ${oldArray[@]} | sed 's/[^ ]*/[&]=&/g') )"

#	declare -gA "$name=( $(echo ${arrayName[@]} | sed 's/[^ ]*/[&]=&/g') )"

	return $TRUE;
}

#
# http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
# http://www.artificialworlds.net/blog/2012/10/17/bash-associative-array-examples/comment-page-1/
#
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

# Admite los argumentos de la function dentro de la function
# y tambien como parametros adicionales en la llamada a la function
function hash.iterate.keys(){
	local name="$1";
	local function="$2";

#	echo array function:[$function];
# Esto coje los parametros de llamada desde la function sin incluir 
# Hasta el ultimo parametro
#	echo array args1:[${@:3:$#}];
#	echo array args2:[$*];


	if ! hash.exists $name ; then
		log.exception The hash $name is nor defined. $*;
	else
#http://bash.cumulonim.biz/FullBashFAQ.html
#http://stackoverflow.com/questions/11776468/create-associative-array-in-bash-3
#http://beggytech.blogspot.be/2010/02/bash-associative-arrays.html

		local array;
		eval array=\( \${!${name}[@]} \);
		for i in "${!array[@]}" ; do

			local key="${array[${i}]}";

#  			log.info.out Iterate over $key;
  			if ! $function ${@:3:$#} "$key" ; then 
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
		local item;
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
		local key;
		for key in $(eval echo '${!'$keyref'}'); do
			valref="${name}[$key]"
#			echo "key = $key"
#			echo "value = ${!valref}"

 			if ! $function "$key" "${!valref}"; then 
  				log.debug Array iteration stoped by client function on key: $key;
  				return $FALSE;
  			fi				

		done
	fi		
	return $TRUE;
}
