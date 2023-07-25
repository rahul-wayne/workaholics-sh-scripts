#!/bin/bash
## To find last working day of a month
var1=`date +%d`
var2=`cal | awk '{ if(NF>1) a=$NF ; if (NF==7) a=$6}END{print a}'`
echo $var1
echo $var2

if [[ $var1 -eq $var2 ]]
then
  /bin/sh /home/test2/test2.sh
else
  echo "both are not equal"
fi
