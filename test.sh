#!/bin/bash

# Calling mnopts returns the original arguments plus the parsed values as the first value
set -- $(./mnopts.sh "long-l short-s" "test.sh [-l|--long] [-s|--short]" "$@")

if [ -z "$1" ]; then exit 1; fi

# Set the parsed variables and remove them
eval "$1"
shift

# Automatic parsed boolean arguments of the form opt_x where x is the short option
echo "opt_l=$opt_l"
echo "opt_s=$opt_s"

echo "$1"
echo "$2"



# RUN
# ./test.sh -l -s arg1 arg2