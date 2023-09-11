#!/bin/bash
#echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#echo "Daylight saving time (DST) is the practice of advancing clocks during summer months by one hour"
#echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#echo "Central Daylight Time (CDT): Second Sunday in March to the first Sunday in November"
#echo "Central Standard Time (CST): Remainder of the year"
#echo "------------------------------------------------------------------------------------"
#echo "Eastern Daylight Time (EDT): Second Sunday in March to the first Sunday in November"
#echo "Eastern Standard Time (EST): Remainder of the year"
#echo "------------------------------------------------------------------------------------"
echo -e "\n"
val=0
current_time=$(date "+%Y-%m-%d %H:%M %Z")
echo Current System time is $current_time
echo -e "\n"
while [[ $val == 0 ]]; do
BC=$'\033[1;31m'
EC=$'\033[0m'
read -r -p  "Enter the date and time in YYYY-MM-DD HH:MM (24Hr) [${BC}IN ANY TIME ZONE${EC}]  format eg: 2023-07-24 14:00 IST:"  inp

if [ -n "$inp" ]
then

CTZ=`date | awk '{print $5}'`
GTZ=`echo $inp | awk '{print $3}'`
tr_inp=`echo $inp | awk '{print $1,$2}'`
FTZ=`date -d "$tr_inp" | awk '{print $5}'`

if [[ "$GTZ" == "EST" || "$GTZ" == "EDT" ]];then
if [[ "$GTZ" != $FTZ ]];then
 echo "You have entered wrong time zone. Please check"
 echo xxxxx Actual Time Zone: $FTZ xxxxx
 echo Given Time: $tr_inp
 echo Current Time Zone is: $CTZ
 echo Given Time Zone is: $GTZ
 exit
fi
fi
BST=`TZ="Europe/London" date -d "$inp" "+%Y-%m-%d %H:%M %Z"`
#echo $BST
if [[ $? -ne 0 ]]
then
  echo "**** ERROR :: INVALID DATE ****"
else
  val=1
  CST=`TZ="America/Costa_Rica" date -d "$BST" "+%Y-%m-%d %H:%M %Z" | awk {'print $NF'}`
  CDT=`TZ="America/Chicago" date -d "$BST" "+%Y-%m-%d %H:%M %Z" | awk {'print $NF'}`
  EST=`TZ="EST" date -d "$BST" "+%Y-%m-%d %H:%M %Z"  | awk {'print $NF'}`
  EDT=`TZ="America/New_York" date -d "$BST" "+%Y-%m-%d %H:%M %Z"  | awk {'print $NF'}`
  echo -e "\n"
  echo "########################################################"
  if [[ "$CST" = "$CDT" && "$EST" = "$EDT" ]]; then
    echo "xxxxxxxxxxxx NOT IN DAYLIGHT SAVING TIME xxxxxxxxxxxx"
    TZ="UTC" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
    TZ="EST" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
    TZ="America/Costa_Rica" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
    TZ="Asia/Kolkata" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
  else
    echo "************ DAYLIGHT SAVING TIME (DST) *************"
    TZ="UTC" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
    TZ="America/New_York" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
    TZ="America/Chicago" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
    TZ="Asia/Kolkata" date -d "$BST" "+%Y-%m-%d %H:%M %Z"
  fi
  echo "########################################################"
  echo -e "\n"
  echo "Daylight Saving Time (DST) is the practice of advancing clocks during summer months by one hour"
  echo  DST - \"From Second Sunday in March to the First Sunday in November\"
fi
else
 val=0
fi
done
