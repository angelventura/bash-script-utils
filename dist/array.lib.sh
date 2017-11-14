#!/bin/bash
#
# Utilities for Arrays and Hasn maps
#

# http://stackoverflow.com/questions/26925905/in-bash-test-if-associative-array-is-declared
# doesn't actually create an associative array immediately; it just sets an attribute on the name FOO which allows you to assign to the name as an associative array. The array itself doesn't exist until the first assignment.		

# Here we store the name of the declared arrays
declare -gA _DECLARED_ARRAYS;

function array.add(){
	local name="$1";
	local value="$2";

	if [ -v $name ] ; then
		eval "$name+=( $value );";
	else
		eval "declare -ga $name=( $value );";
		# adding a new declared array
		eval "_DECLARED_ARRAYS[\"$name\"]=\"$name\";";
	fi

	return $TRUE;
#
#	echo $name;
}

# function array.size(){
# 	local name="$1";
# 	local s1="${#";
# 	local s2="[@]}"

# 	log.info.out NAME::::: $name;

# 	local string="$s1""$name""$s2";

# 	log.info.out SIZE::::: $string;
# 	eval "$string";

# 	log.info.out RET::::: $ret;

# 	return $TRUE;
# }

function array.create(){
	local name="$1";

#	log.exception.out $name;
#	log.info.out name[$name];

	if [ -v $name ] ; then
		log.warn Already existing array:$name. $*. Another object with the same name already exits.;
	else
		eval "declare -ga $name;";
		# adding a new declared array
		eval "_DECLARED_ARRAYS[\"$name\"]=\"$name\";";
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

#	if [[ -v "$name" ]] ; then
#		return $TRUE;
#	else
#		return $FALSE;
#	fi

	if [ "$name" == "_DECLARED_ARRAYS" ] ; then
		log.exception.out Asking for array exists:_DECLARED_ARRAYS ...
		return $TRUE;
	fi

	if eval "test \${_DECLARED_ARRAYS[$name]+_} " ; then
		# log.info.out EXISTS: $name;
				
		return $TRUE;
	else
		# log.info.out NOT EXISTS: $name;
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
	array.exists "$1";

	return $?;
}

function hash.name(){
	local name="$1";
	
	echo ${name//[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789]/_};
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
#		eval "declare -gA $name;";
		hash.create "$name"
	fi

	eval "$name[\"$key\"]=\"$value\";";

	return $TRUE;
#	echo $variable;
}

function hash.remove(){
	local name="$1";
	local key="$2";

	if [ "$key" == "" ] ; then
		log.exception $name adding a empty key.
		return $FALSE;
	fi

	if ! hash.exists "$name" ; then
		log.exception The hash $name does not exists.
		return $FALSE;
	fi

	eval "unset $name[\"$key\"];";

	return $TRUE;
}

function hash.create(){
	local name="$1";
	
	if ! hash.exists "$name" ; then
		# http://stackoverflow.com/questions/10806357/associative-arrays-are-local-by-default
		# Associative arrays
		eval "declare -gA \"$name\"";

#		hash.add "_DECLARED_ARRAYS" "$name" "$name";
		eval "_DECLARED_ARRAYS[\"$name\"]=\"$name\";";
# http://stackoverflow.com/questions/26925905/in-bash-test-if-associative-array-is-declared
# doesn't actually create an associative array immediately; it just sets an attribute on the name FOO which allows you to assign to the name as an associative array. The array itself doesn't exist until the first assignment.		

		# log.info.out Created hash: $name;
	fi

	if ! hash.exists "$name" ; then
		log.exception.out Fatal error creating hash [$name];
		batch.exitError Fatal error creating hash [$name];
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

	if ! hash.exists "$name" ; then
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

# Print all the keys into one string ussing the separator passed in param.
function hash.keys.print(){
	local name="$1";
	local separator="$2";


	if ! hash.exists "$name" ; then
		log.exception The hash $name is nor defined. $*;
		echo "";
	else
		local array;
		local prevKey="";
		eval array=\( \${!${name}[@]} \);
		for i in "${!array[@]}" ; do

			local key="${array[${i}]}";

			if [ "$prevKey" != "" ] ; then
				printf "$separator$key";
			else
				printf "$key";
			fi

			prevKey=$key
		done
	fi		
	return $TRUE;
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


	if ! hash.exists "$name" ; then
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

	if ! hash.exists "$name" ; then
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

	if ! hash.exists "$name" ; then
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
