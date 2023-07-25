#!/bin/bash
USERNAME=root
read -r -p "Please enter USER NAME: " user_name
read -r -p "Please enter PASS HASH: " pswd_hash
echo "USER NAME = $user_name"
if [[ -z "$user_name" || "$user_name" = "$USERNAME" ]]; then
    echo "This is not permitted"
else
for HOSTNAME in `cat /tmp/vmlist/pass_rst/vmlist.txt` ; do
    echo $HOSTNAME;
    ssh -l ${USERNAME} ${HOSTNAME} "if id '$user_name' &>/dev/null; then usermod -p '$pswd_hash' $user_name; grep $user_name /etc/shadow; else echo 'user not found';fi"
done
fi

