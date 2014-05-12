#!/bin/bash
#
# $HeadURL$
# $Id$
# $Format:%H$
#
# Unitary test lib
#

function assert.equal(){
	local name="$1";
	local arg1="$2";
	local arg2="$3";

	if [ "$arg2" == "" ] ; then
		arg1="$1";
		arg2="$2";		
	fi

	if [ "$arg1" != "$arg2" ] ; then
		batch.exitError $name: arguments are not equals \"$arg1\" != \"$arg2\";
	else
		echo Test ok: $name
	fi	
}

function assert.notequal(){
	local name="$1";
	local arg1="$2";
	local arg2="$3";

	if [ "$arg2" == "" ] ; then
		arg1="$1";
		arg2="$2";		
	fi

	if [ "$arg1" != "$arg2" ] ; then
		echo Test ok: $name
	else
		batch.exitError $name: arguments are equals \"$arg1\" != \"$arg2\";
	fi	
}

function assert.true(){
	local command="$1";

	eval $command;

	if [ $? -eq 0 ]; then
		echo Test ok: true \($command\);
	else
		batch.exitError $command: Returns error, ok attended.;
	fi;
}

function assert.false(){
	local command=$1;
	
	eval $command;
	
	if [ $? -eq 0 ]; then
		batch.exitError $command: Returns ok, error attended.;
	else
		echo Test ok: false \($command\);
	fi;
}


function assert.dir.exists(){
	local test="$1";
	local file="$2";

	if [ "$file" == "" ] ; then
		file="$1";
	fi

	if [ -d "$file" ]; then 
		echo Test ok: $test dir exists \"$file\";		
	else
		batch.exitError $test: dir does not exists \"$file\".;
	fi
}

function assert.file.exists(){
	local test="$1";
	local file="$2";

	if [ "$file" == "" ] ; then
		file="$1";
	fi

	if [ -f "$file" ]; then 
		echo Test ok: $test file exists:\"$file\";		
	else
		batch.exitError $test: file does not exists:\"$file\".;
	fi
}

function assert.file.notExists(){
	local test="$1";
	local file="$2";

	if [ "$file" == "" ] ; then
		file="$1";
	fi

	if [ ! -f "$file" ]; then 
		echo Test ok: $test do not file exists:\"$file\";		
	else
		batch.exitError $test: file exists:\"$file\".;
	fi
}

