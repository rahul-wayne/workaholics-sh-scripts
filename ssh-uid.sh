#!/bin/bash
USERNAME=root
read -r -p "Please enter USER ID: " user_id
echo "USER ID = $user_id"
for HOSTNAME in `cat /tmp/vmlist/vmlist.txt` ; do
    echo $HOSTNAME;
    ssh -l ${USERNAME} ${HOSTNAME} "grep -E '$user_id' /etc/passwd";
done

