#!/bin/bash
##collect server details over ssh##

USERNAME=`whoami`
read -r -p "Enter full path of ip list:" ip_list
read -r -s -p "Please enter password for the user $USERNAME: " pass
echo -e "\n"
read -r -p "Enter your mail id to get the report:" mail_id

out_file=Inventory_final_file-`date +%Y%m%d-%H%M%S`.csv
cmd_var="hostname| tr -d '\n' | sed 's/$/,/'"
cmd_var2="grep -i '^version=' /etc/os-release | sed 's/[[:space:]]//g'| tr -d '\n' | sed 's/$/,/'"
cmd_var3="remote_var=\$(sudo fdisk -l| grep -i 'data:' | awk '{print \$2 \$3 \$4}'| tr -d '\n' |sed 's/,*$//g'|sed 's/$/,/');if [[ ! -z \$remote_var ]]; then echo \$remote_var|tr -d '\n';else echo NA,|tr -d '\n';fi"
cmd_var4="nproc| tr -d '\n' | sed 's/$/,/'"
cmd_var5="free -h|grep 'Mem:' |awk '{print \$2}'"
echo "Please find the attached inventory" > mail_body
echo -e "\n"
echo -e "Please wait while creating details\n"
echo "IP ADDRESS,HOSTNAME,OS VERSION,DATA DISK,CPU CORE,RAM MEMORY" >> $out_file
for HOSTNAME in `cat $ip_list` ; do
    sshpass -p $pass ssh -o StrictHostKeyChecking=no -l ${USERNAME} ${HOSTNAME} "echo '$HOSTNAME', |tr -d '\n'; $cmd_var; $cmd_var2; $cmd_var3; $cmd_var4; $cmd_var5" >> $out_file
done
echo "$out_file"
##mail module##
mail -r 'No Reply <example@mail.com>' -s "Inventory list" -a $out_file  $mail_id < mail_body
echo -e "\n... Please check the mail of $mail_id for Inventory list ..."

rm mail_body
rm $out_file
