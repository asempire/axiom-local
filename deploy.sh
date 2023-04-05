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

#make ssh_config file from csv file
############################################
if [[ -f ~/.axiom/ssh_config ]];
then
    echo "ssh_config already exists and will be regenerated"
    rm ~/.axiom/ssh_config
fi

if [[ -f ~/.axiom/selected.conf ]];
then
    echo "selected.conf already exists and will be regenerated"
    rm ~/.axiom/selected.conf
fi
while IFS= read -r line
do 
    host="$(echo $line | cut -d',' -f 1)"
    user="$(echo $line | cut -d',' -f 2)"
    ip="$(echo $line | cut -d',' -f 3)"
    echo -e "Host $host\n\tHostname $ip\n\tUser $user"  >> ~/.axiom/ssh_config
    echo -e "$host" >> ~/.axiom/selected.conf
done <<< $(cat $file)
############################################




#push installation script to hosts
############################################
for line in $(cat $file)
do
    host="$(echo $line | cut -d',' -f 1)"
    user="$(echo $line | cut -d',' -f 2)"
    ip="$(echo $line | cut -d',' -f 3)"
    pass="$(echo $line | cut -d',' -f 4)"
    root_pass="$(echo $line | cut -d',' -f 5)"
    sshpass -p $pass ssh-copy-id -f -i ~/.ssh/axiom_rsa.pub -o StrictHostKeyChecking=no $user@$ip 
    if ssh $user@$ip '[ -d ~/axiom-local ]';
    then
        echo "config directory exists and won't be copied"
    else 
       scp -r . $user@$ip:"~/axiom-local"  
    fi
    ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $user@$ip "cd ~/axiom-local && ./axiom-local-install.sh -u $pass -r $root_pass &> /dev/null" &
done
############################################