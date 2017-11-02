#!/bin/bash

set -x

MODE="$1"
shift

stack build --only-dependencies

case "$MODE" in
"build")
	exec ghcid \
		--no-title \
		--command="stack exec -- ghci -ilib:src:tests -Wall ${1}" \
;;

"run")
	exec ghcid \
		--no-title \
		--command="stack exec -- ghci -ilib:src:tests ${1}" \
		--test=":main ${*:2}"
;;

"test")
	exec ghcid \
		--no-title \
		--command="stack exec -- ghci -ilib:src:tests ${1}" \
		--test=":main --color ${*:2}"
;;

"explore")
	exec stack exec -- ghci -ilib:src:tests "${1}"
;;

*)
	echo "Need a mode; one of {build, run, explore}"
	exit 1

esac

