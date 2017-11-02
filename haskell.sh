#!/bin/bash

MODE="$1"
shift

case "$MODE" in
"build")
	set -x
	stack build --only-dependencies
	ghcid \
		--no-title \
		--command="stack exec -- ghci -ilib:src:tests -Wall ${1}" \
;;

"run")
	set -x
	stack build --only-dependencies
	ghcid \
		--no-title \
		--command="stack exec -- ghci -ilib:src:tests ${1}" \
		--test=":main ${*:2}"
;;

"test")
	set -x
	stack build --only-dependencies
	ghcid \
		--no-title \
		--command="stack exec -- ghci -ilib:src:tests ${1}" \
		--test=":main --color ${*:2}"
;;

"explore")
	set -x
	stack build --only-dependencies
	stack exec -- ghci -ilib:src:tests "${1}"
;;

*)
	cat <<HERE
Usage: `basename $0` <mode> <filename>

Where mode is one of:
  build		Continuously build the given Haskell file.

  run		Build the given source file, then on success,
		run the \`main\` function. When the sources
		change the process will be terminated and the
		code rebuilt.

  test		Same, but appends \`--color\` to arguments so
		hspec's output is colourized.

  explore	Build the given source file and its dependencies,
		then on success, fire up GHCi with the given
		module loaded.

Examples:
	$ haskell build lib/Data/Time/Gregorian.hs
	$ haskell run src/AlarmClock.hs
	$ haskell explore tests/Experiment.hs
	$ haskell test tests/TestSuite.hs

HERE
	exit 1
	;;
esac

exit 0
