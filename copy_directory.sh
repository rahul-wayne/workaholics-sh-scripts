#!/usr/bin/bash
#Purpose: To copy files from one server to another via a centralized server
#Authors: Gigith, Rahul

clear
echo "------------------------------------------------"
echo "This script is used to copy file/directory from"
echo "one server to another via a centralized server."
echo "------------------------------------------------"
echo -e "\n"

USER=root
var=1
while [ $var = 1 ];do

   read -r -p "Enter source ip address:" source_ip
   read -r -p "Enter destination ip address:" dest_ip

   if [[ $source_ip =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ && $dest_ip =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then 
    ping -c 1 "$source_ip" > /dev/null
    if [ $? -eq 0 ]; then
     echo "node $source_ip is up" 
    else
     echo "node $source_ip is down, please enter a reachable source ip"
     exit
    fi
    ping -c 1 "$dest_ip" > /dev/null
    if [ $? -eq 0 ]; then
     echo "node $dest_ip is up" 
    else
     echo "node $dest_ip is down, please enter a reachable destination ip"
     exit
    fi
   var=0 
   else
   var=1
   fi
done

var=1
while [ $var = 1 ]; do
   read -r -p "Enter full path of source directory to be copied:" source_dir
   result1=$(ssh -l $USER $source_ip 'bash -s' << EOF
    if [[ -d "$source_dir" || -f "$source_dir" ]];then
       echo "exist"
    else
       echo "not_exist"
    fi
EOF
)
     if [[ "$result1" == "exist" ]];then
       echo "$source_dir $result1 in $source_ip"
       var=0
     else
       echo "$source_dir $result1 in $source_ip"
       var=1
     fi
done

var=1
while [ $var = 1 ];do
   read -r -p "Enter full path of destination directory(must be inside /tmp):" dest_dir
   dest_var=`echo "$dest_dir"|cut -d "/" -f 2`
    if [[ "$dest_var" == "tmp" ]];then
       cmd="if [[ -d $dest_dir || -f $dest_dir ]]; then echo 'exist'; else echo 'not_exist';fi"
       ssh -l $USER $dest_ip "$cmd" > result_file
       result2=`cat result_file`
       if [[ "$result2" == "exist" ]];then
         echo "$dest_dir $result2 in $dest_ip"
         var=0
       else
         echo "$dest_dir not_exist in $dest_ip"
       fi
    else
       var=1
    fi
done
rm result_file

source_size1=`ssh -l $USER $source_ip "sudo du -s $source_dir"`
source_size=`echo $source_size1 | awk '{print $1}'`
total_dest_tmp_size1=`ssh -l $USER $dest_ip "df /tmp|grep '/tmp'"`
total_dest_tmp_size=`echo $total_dest_tmp_size1 | awk '{print $2}'`
avail_dest_tmp_size=`echo $total_dest_tmp_size1 | awk '{print $4}'`
post_cpy_size=`echo "$avail_dest_tmp_size-$source_size"|bc`
exp_free_size=`echo "$total_dest_tmp_size/4"|bc`

src_in_mb=`echo "$source_size/1024"|bc`
dst_avil_mb=`echo "$avail_dest_tmp_size/1024"|bc`
post_cp_mb=`echo "$post_cpy_size/1024"|bc`

if [[ $source_size -lt $avail_dest_tmp_size && $post_cpy_size -gt $exp_free_size ]];then
   
   echo "------------------------------------------------------------------"
   echo "Total source directory/file size in MB: $src_in_mb MB"
   echo "Toatal available free space in [/tmp]: $dst_avil_mb MB"
   echo "Total available free space in [/tmp] post copying: $post_cp_mb MB"
   echo "------------------------------------------------------------------"
  
   var=1
   while [ $var = 1 ];do 
     read -r -p "Dou you want to continue [YES/NO]?:" ans
      if [[ $ans == "YES" ]];then
       echo "Copying $source_dir from $source_ip to $dest_dir on $dest_ip"
       scp -r $USER@$source_ip:$source_dir $USER@$dest_ip:$dest_dir
       var=0   
      elif [[ $ans == "NO" ]];then
       echo "Exiting........"
       exit
      else
       var=1
      fi
   done
else
   echo "------------------------------------------------------"
   echo "copy not possible file size is too large"
   echo "Total source directory/file size in MB: $src_in_mb MB"
   echo "Toatal available free space in [/tmp]: $dst_avil_mb MB"
   echo "------------------------------------------------------"
fi
