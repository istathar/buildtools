#!/bin/bash 
#
# Continuous rebuilding for software, driven by inotify.
# 
# Copyright © 2011      Mega Nerd, Pty Ltd
# Copyright © 2011-2012 Operational Dynamics Consulting, Pty Ltd
#
# The code in this file, and the program it is a part of, is made available
# to you by its authors as open source software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License version
# 2 ("GPL") as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GPL for more details.
#
# You should have received a copy of the GPL along with this program. If not,
# see http://www.gnu.org/licenses/. The authors of this program may be
# contacted through http://research.operationaldynamics.com/

#
# Watch the current directory for changes and run `make` when any of them
# changes on disk. Following a successful build, run the supplied program
# until a subsequent change, on which event terminate the program and
# retry the build.
# 

#
# The `inotifywait` program is sufficiently odd-ball that we test for it first.
# 

if [ ! -x "/usr/bin/inotifywait" ] ; then
	echo "ERROR: This uses the inotifywait program, which on a Debian-based system is"
	echo "part of the 'inotify-tools' package. Please install that and try again."
	exit 1
fi 

#
# Make targets can be listed on the command line when invoking. The service to
# be run on a successful build is given by the first argument given after -- to
# the script. For example,
#
# 	$ inotifymake -- ./program
# 	$ inotifymake test
#	$ inotifymake test -- ./program
#

while [ $# -gt 0 ] ; do
	if [ "$1" == "--" ] ; then
		shift
		break
	fi
	TARGETS="$TARGETS $1"
	shift
done

if [ $# -gt 0 ] ; then
	PROGRAM="$@"
else
	PROGRAM=""
fi


#
# Start by running a build.
#

while true ; do
	clear
	make $TARGETS

#
# Assuming the build succeeded, run the program in the background, then loop
# back to inotify.
#

	if [ $? -eq 0 ] && [ "$PROGRAM" ] ; then
		echo -e "EXEC\t$PROGRAM"
		$PROGRAM &
		PID="$!"
		sleep 0.1
	else
		PID=""
	fi

#
# Wait for a file to be "saved" In this directory. Arguments to inotify:
#
# -q   
#	   Quiet; twice means not to output anything.
#
# -r	
#	   Recursive.
#
# -e	
#	   Event to watch for.
#
# --exclude
#	   Exclude Vim swap files .swp, swx, .swpx and its file creation test
#	   file 4913 and its temporary file written with a ~ suffix.
#
# This blocks until the condition arises...
#

	inotifywait -q -q -r -e 'close_write' \
		--exclude '^\..*\.sw[px]*$|4913|~$|.git/.*\.lock$|.*i\.log$' .

#
# ... so now a "save" has happened. If the program is running, kill it, then
# loop back to run the build.
#

	if [ "$PID" ] ; then
		kill $PID
	fi

done

