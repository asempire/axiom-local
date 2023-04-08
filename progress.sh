#!/bin/bash

while getopts 'hf:' OPTION; do
    case "$OPTION" in
    h)
        echo "usage: $(basename $0) -f <csv file>" >&1
        exit 0
        ;;
    f)
        file="$OPTARG"
        ;;
    :)
        echo "missing argument for -%s\n" "$OPTARG" >&2
        echo "usage: $(basename $0) -f <csv file>" >&2
        exit 1
        ;;
    ?)
        echo "usage: $(basename $0) -f <csv file>" >&2
        exit 1
        ;;
    esac
done
shift "$(($OPTIND -1))"

if [[ ! "$file" ]];
then
    echo "missing flag -f" >&2
    echo "usage: $(basename $0) -f <csv file>" >&2
    exit 1
fi

for line in $(cat $file)
do
    host="$(echo $line | cut -d',' -f 1)"
    user="$(echo $line | cut -d',' -f 2)"
    ssh -F ~/.axiom/.sshconfig -i ~/.ssh/axiom_rsa -q $user@$host [[ -f "~/axiom-local/configs/complete_install" ]] && echo "installation for $host finished" || echo "installation for $host not finished yet";
done
