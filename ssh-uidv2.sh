#!/bin/bash
USERNAME=`whoami`
#USERNAME=root
read -r -p "Please enter USER ID: " user_id
read -r -p "Enter full path of ip list:" ip_list
read -r -s -p "Please enter your password for the user $USERNAME: " pass
echo "USER ID = $user_id"
cmd_var="grep -E '$user_id' /etc/passwd"
for HOSTNAME in `cat $ip_list` ; do
    echo $HOSTNAME;
    sshpass -p $pass ssh -o StrictHostKeyChecking=no -l ${USERNAME} ${HOSTNAME} "$cmd_var";
done
