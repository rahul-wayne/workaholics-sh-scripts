#!/bin/bash

echo "1.Server resource check"
echo "2.Check ping"
echo "3.Check OS version"
echo "4.Slowness check"
echo "5.Time zone convert"
echo -e "\n"
var=0
while [ $var = 0 ]; do
read -r -p "Enter your choice:" ans

if [[ -n $ans && "$ans" -le "5" ]]; then

case "$ans" in
   "1") echo "Running server resource check........."; sh resource.sh
   ;;
   "2") echo "Running ping check........"; sh pingall.sh
   ;;
   "3") echo "Checking OS version......"; sh os-version.sh
   ;;
   "4") echo "Running slowness check......"; sh slowness_chk.sh
   ;;
   "5") echo "Executing time zone converter....."; sh time_zone_convert.sh
   ;;
esac
var=1
fi
done
