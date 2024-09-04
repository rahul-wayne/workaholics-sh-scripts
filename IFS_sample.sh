# To overcome spaces in keywords. 
# new line is taken as Internal Field Separator (IFS) instead of space

# 1. Save old $IFS
oldIFS="$IFS"

# 2. Now set up a new value to :
IFS=$'\n'

for i in `cat ref_file`; do echo "$i"; done

# 3. Restore $IFS
IFS="$oldIFS"
