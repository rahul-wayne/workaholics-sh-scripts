#!/bin/bash

USERNAME=root
iplist=all_server_list
BC=$'\033[1;31m'
EC=$'\033[0m'
BCG=$'\033[1;32m'
BCB=$'\033[1;96m'
var=1
while [ "$var" = 1 ];do
read -r -p "Please enter USER NAME: " user_name
if [[ -z "$user_name" ]];then
   echo  "${BC}User name cannot be empty!${EC}"
   var=1
elif [[ "$user_name" == "root" ]];then
   echo "${BC}This is not permitted you cannot reset the password of root!${EC}"
else
var=0
fi
done
var=1
while [ "$var" = 1 ];do
read -r -s -p "Please enter PASSWORD: " pssword
echo -e "\n"
if [[ -z "$pssword" ]];then
   echo "${BC}Password cannot be empty!${EC}"
   var=1;
else
var=0
fi
done
if [[ -z "$user_name" || "$user_name" == "root" || -z "$pssword" ]]; then
    echo "This is not permitted"
    exit
else
var=1
while [ "$var" = 1 ];do
read -r -p "${BC}Do you want to continue password reset for the user $BCB$user_name${BC} [YES/NO]: ${EC}" resp
echo -e "\n"
if [[ "$resp" == "NO" ]];then
  echo "Exiting script....."
  exit
elif [[ "$resp" == "YES" ]];then
for i in `cat $iplist`;do
ssh -l ${USERNAME} $i 'bash -s' << EOF
if getent passwd $user_name > /dev/null 2>&1; then
    echo "$user_name:$pssword" | sudo chpasswd
    echo -e "${BCG}Successfully changed password on $i ${EC}"
    exit 1
else
    echo "${BC}$user_name, user not found in $i${EC}"
fi
EOF
done
var=0
else
var=1
fi
done
fi
