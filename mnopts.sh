#!/bin/bash

# mnopts
# Usage: ./mnopts.sh "argument-a option-o flag-f" "usage string" "$@"
# First argument is space separated strings of the form full-x where 
#   'full' sets up the long-form option (in this case it will be --full) and 
#   'x' sets up the short-form option (in this case 'x')
# Second argument is a string which is printed whenever help or an incorrect set of options is invoked
# The full arguments of the calling script should also be passed as "$@"

# Note: help-h is an automatic option which invokes the usage statement

# Parse the first argument as an array
allOptions=($1)

# Set the usage statement from the second argument
usage="Usage: $2"

# Drop the above 2 positional arguments
shift 2

# Build a list of the valid short-form options and set up the automatic bool variables
shortOptions=""
for option in ${allOptions[@]}
do
    IFS='-' read -ra optionPair <<< "$option"
    declare opt_${optionPair[1]}=false
    shortOptions="$shortOptions${optionPair[1]}"
done

# Match the arguments passed from the calling script against the options
for arg in "$@"
do
    shift
    optionMatched=false

    # Check the passed option against all registered options
    for option in ${allOptions[@]}
    do

        # Get the 'long form'
        IFS='-' read -ra optionPair <<< "$option"

        # Use it to set the 'short' form
        if [ "$arg" == "--${optionPair[0]}" ]
        then
            optionMatched=true
            set -- "$@" "-${optionPair[1]}"
        fi
    done

    # If not in the registered list, echo usage and exit
    if [ "$optionMatched" == "false" ]
    then
        set -- "$@" "$arg"
    fi
done

# Use standard getopts setup now that long-form options have been converted to short
OPTIND=1
while getopts "$shortOptions" opt 2> /dev/null
do
    case "$opt" in
        "?")    echo "$usage" >&2 && exit 1 ;; 
        "h")    echo "$usage" && exit 0 ;; 
        *)      declare opt_${opt}=true ;;
    esac
done
shift $(expr $OPTIND - 1)

# Build up the ouput which involves a list of variable values and the original variables
output=""
for option in ${allOptions[@]}
do
    IFS='-' read -ra optionPair <<< "$option"
    varName="opt_${optionPair[1]}"
    output="${output}opt_${optionPair[1]}=${!varName}&&" 
done
output="${output}:" 

# Echo the output so that the calling script can use it
echo "$output $@"