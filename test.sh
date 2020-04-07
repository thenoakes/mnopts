#!/bin/bash

# Usage: source ./mnopts.sh options usage-statement "$@"
source ./mnopts.sh "long:l short:s another:a" "test.sh [-l|--long] [-s|--short] [-a|--another]" "$@"

# Automatic parsed boolean arguments of the form opt_x where x is the short option
echo "opt_l=$opt_l"
echo "opt_s=$opt_s"
echo "opt_a=$opt_a"

echo "$1"
echo "$2"



# RUN
# ./test.sh -l -s arg1 arg2