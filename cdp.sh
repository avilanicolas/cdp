#!/bin/bash
# add this to your zshrc:
# function cdp() {
# 	to=$(. <PATH TO CDP>/cdp.sh $@)
# 	test $? = '0' && test -d $to && cd $to
# }
#
# this function is needed so cdp can cd in the same shell as the cli
# this script, on its own, only prints the directory it will cd to stdout
# all other messages will be emitted to stderr

_CDP_DEFAULT=$HOME/paths

function _defineCdpPath() {
	if [ -z $CDPPATH ]; then
		echo "[cdp] First time using cdp, defining: \$CDPATH">&2
		echo "[cdp] No input to use the default path.">&2
		echo -n "[$_CDP_DEFAULT]: ">&2

		read userPath

		if [ -z $userPath ]; then
			userPath=$_CDP_DEFAULT
			echo "[cdp] using default $userPath">&2
		else
			echo "[cdp] using $userPath">&2
		fi;

		eval userPath=$userPath

		if [ ! -d $userPath ]; then
			echo "[cdp] '$userPath' not a directory, dying.">&2
			exit 1
		fi;

		export CDPPATH=$userPath
	fi;
}

_defineCdpPath

target=$1
if [ -z $1 ]; then
	target=".last"
fi;

if [ "$1" = "new" ]; then
	newpath=$(pwd)
	echo -n "$newpath" > $CDPPATH/$2
	echo "[cdp] saved new path $2 to $newpath">&2
	exit 1
elif [ "$1" = "-h" ]; then
	cat <<'EOF' >&2
cdp - 'cd path' shell util

flags:
	-h This help prompt

usage:
	# create a new cdp path with `cdp new <PATHNAME>`
	$ mkdir -p /tmp/foo && cd /tmp/foo
	$ cdp new foo
	$ mkdir -p /tmp/bar && cd /tmp/bar
	$ cdp new bar

	# you can cd into cdp paths quickly with `cdp <PATHNAME>`
	$ cdp foo
	$ pwd
	/tmp/foo
	$ cdp bar
	$ pwd
	/tmp/bar

	# if you cdp into any path, you can always revert to the last path with just `cdp`
	$ cdp
	$ pwd
	/tmp/foo

notes:
	cdp Uses stores saved paths to a directory stored at $CDPPATH

	If this variable is not set, when cdp runs for the first time (or the variable is not set),
	it will ask you for a directory to use.
EOF
	exit 1
fi;

targetPath=$CDPPATH/$target

cat $targetPath | read newPath
if [ -z $newPath ]; then
	echo "[cdp] no path found by $target (looking up $targetPath)" >&2
	exit 1
fi;

if [ ! -d $newPath ]; then
	echo "[cdp] '$newPath' is not a directory" >&2
	exit 1
fi;

pwd > $CDPPATH/.last

echo $newPath >&1
exit 0
