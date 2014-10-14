#!/bin/bash
#
# load properties from file
#

# Test for several includes
if [ "$__PROP_LIB_SH" != "" ] ; then
	log.debug Aditional include __PROP_LIB_SH[$__PROP_LIB_SH];
	return $TRUE;
else
	__PROP_LIB_SH="__PROP_LIB_SH";
	log.debug first include __PROP_LIB_SH[$__PROP_LIB_SH];
fi


util.load.library array

hash.create "_PROP_HASH";

# 
# Returns file key
function prop.file.key(){
	local fileId="$1";

	echo "_PROP_HASH-$fileId";
}

# Returns the property key
function prop.name.key(){
	local fileId="$1";
	local name="$2";

	echo "$fileId-$name";
}


# Tells if this file id has been already loaded
#
function prop.file.already.loaded(){
	local key=$(prop.file.key "$1");
	
#	log.debug $key;

	hash.key.exist "_PROP_HASH" "$key";
	local ret=$?;

#	log.debug ret $(error.code.display $ret);

	return $ret;
}

function prop.data.store(){
	local fileId="$1";
	local name="$2";
	local value="$3";
	
	local key=$(prop.name.key "$fileId" "$name");

	hash.add "_PROP_HASH" "$key" "$value";

	return $TRUE;
}

# Thos retuns string properties only
function prop.data.get(){
	local fileId="$1";
	local name="$2";

	local key=$(prop.name.key "$fileId" "$name");
	
	hash.get "_PROP_HASH" "$key";

	return $TRUE;
}

# Thos retuns string properties only
function prop.load(){
	local fileId="$1";
	local path="$2";
	local arrayName="$3";

	if prop.file.already.loaded "$fileId" ; then
		log.debug Props already loaded for file:$fileId ...;
		return $TRUE;
	else

		if [ ! -e "$path" ] ; then
			log.exception The property file does not exists [$path].
			return $FALSE;
		fi

		local array="${arrayName}[@]"
		# Clear values from precedent charge
		local item;
		for item in "${!array}"; do

#			log.debug Previous Value $item:[${!item}];

			declare $item="";

#			log.debug Must be zero $item:[${!item}];

		done;

		# Read the values
		. "$path";

		# Store the values
		for item in "${!array}"; do

			prop.data.store "$fileId" "$item" "${!item}";
		done;
		
		return $TRUE;		
	fi		
}


# Thos retuns string properties only
function prop.put(){
	local fileId="$1";
	local path="$2";
	local name="$3";
	local value="$4";

	if [ ! -e "$path" ] ; then
		log.exception The property file does not exists [$path].
		return $FALSE;
	fi

	local count=`grep -c $name $path`;
	log.info Count:[$count] [$name] [$value];

# check is a number

	if [ "$count" -eq "0" ] ; then
		log.info File:[$path], do not have the property:[$name]. Adding ...

		echo "" >> $path;
		echo "# Auto prop added " >> $path;
		echo "$name=\"$value\"" >> $path;
		return $TRUE;
	else

		log.info Executing sed comand on file $path
		
		if ! sed -i".back" "s|^$name.*=.*$|$name=\"$value\"|g" $path ; then 
			log.exception While executing command [sed -i ".back" "s|^$name.*=.*$|$name=\"$value\"|g" $path]
			
			return $FALSE;
		else
			local key=$(prop.name.key "$fileId" "$name");
			prop.data.store "$fileId" "$key" "$value";
			
			return $TRUE;		
		fi
	fi
		
#bash -c 'echo -e "\nserver.id='$1'" >> file.properties'

	
}

function prop.value.isTrue(){
	local arg="$1"

	if [ "$arg" == "" ] ; then
		return $FALSE;
	elif  [ "$arg" == "true" ] ; then
		return $TRUE;
	elif  [ "$arg" == "0" ] ; then
		return $FALSE;
	elif  [ "$arg" == "1" ] ; then
		return $TRUE;
	elif  [ "$arg" == "TRUE" ] ; then
		return $TRUE;
	else
		return $FALSE;
	fi
}
