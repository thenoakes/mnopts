#!/bin/bash

# mnopts
# Usage: source ./mnopts.sh "argument:a option:o flag:f" "usage string" "$@"
# First argument is space separated strings of the form full:x where 
#   'full' sets up the long-form option (in this case it will be --full) and 
#   'x' sets up the short-form option (in this case 'x')
# Second argument is a string which is printed whenever help or an incorrect set of options is invoked
# The full arguments of the calling script should also be passed as "$@"

# Note: help:h is an automatic option which invokes the usage statement

MNOPTS="$1"
MNOPTS_USAGE="$2"
shift 2

# A function which checks a value against values in an array
checkDuplicate () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

dupeError() {
    local dupe="$1"
    echo "mnopts setup error: duplicate option '$dupe'"
    exit 1
}

set_longOpt_shortOpt() {
    local pair="$1"
    IFS=':' read -ra optionPair <<< "$pair"
    longOpt="${optionPair[0]}"
    shortOpt="${optionPair[1]}"
}


# Only act if MNOPTS are supplied
if [ ! -z "$MNOPTS" ]; then

    # BEGIN PARSING

    allOptions=($MNOPTS)

    # Build a list of the valid short-form options and set up the automatic bool variables
    allLong=()
    allShort=()
    for option in ${allOptions[@]}
    do
        set_longOpt_shortOpt "$option"

        # If either the long or short options already exist, bail out
        checkDuplicate "$longOpt" "${allLong[@]}" && dupeError "$longOpt"
        checkDuplicate "$shortOpt" "${allShort[@]}" && dupeError "$shortOpt"

        # Add the long & short options to a list, and set the default value for the variable
        allLong+=("$longOpt")
        allShort+=("$shortOpt")
        declare opt_${shortOpt}=false
    done

    # Set a custom or automatic usage statement
    if [ ! -z "$MNOPTS_USAGE" ]; then
        usage="Usage: $MNOPTS_USAGE"
    else
        usage="script-name"
        for opt in ${allOptions[@]}
        do
            set_longOpt_shortOpt "$opt"
            usage+=" [-${shortOpt}|--${longOpt}]"
        done
    fi

    # Match the arguments passed from the calling script against the options
    for arg in "$@"
    do
        shift
        optionMatched=false

        # Check the passed option against all registered options
        for option in ${allOptions[@]}
        do

            # Get the 'long form'
            set_longOpt_shortOpt "$option"

            # Use it to set the 'short' form
            if [ "$arg" == "--${longOpt}" ]
            then
                optionMatched=true
                set -- "$@" "-${shortOpt}"
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
    while getopts "$(printf "%s" "${allShort[@]}")" opt 2> /dev/null
    do
        case "$opt" in
            "?")    echo "$usage" >&2 && exit 1 ;; 
            "h")    echo "$usage" && exit 0 ;; 
            *)      declare opt_${opt}=true ;;
        esac
    done
    shift $(expr $OPTIND - 1)

    # END PARSING

fi