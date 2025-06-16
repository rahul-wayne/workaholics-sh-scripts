#!/bin/bash
#Date: 14-Jun-2025
#Purpose: To send Shift Handover

clear

# CONFIGURATION (change below values)
EMAIL_TO="support@gmail.com"
TEAM_NAME="Support"

ENGINEERS=("User1"
           "User2" 
           "User3")

SHIFTS=("Morning" 
        "General" 
        "Evening" 
        "Night")

COLUMNS=1

# Escape HTML
escape_html() {
    sed -e 's/&/\&amp;/g' \
        -e 's/</\&lt;/g' \
        -e 's/>/\&gt;/g' \
        -e 's/"/\&quot;/g' \
        -e "s/'/\&#39;/g"
}

# Collect Inputs
#read -p "Enter Team Name: " TEAM_NAME

# Prompt for Engineer Name
PS3="Choose Engineer (1-${#ENGINEERS[@]}): "
select ENGINEER in "${ENGINEERS[@]}"; do
    [[ -n "$ENGINEER" ]] && break
    echo "Invalid selection."
done

echo -e "\n"

# Prompt for Shift
PS3="Choose Shift (1-${#SHIFTS[@]}): "
select SHIFT in "${SHIFTS[@]}"; do
    [[ -n "$SHIFT" ]] && break
    echo "Invalid selection."
done

#read -p "Enter Report Date (YYYY-MM-DD) [default: today]: " REPORT_DATE
#REPORT_DATE=${REPORT_DATE:-$(date +%F)}
REPORT_DATE=$(TZ="Asia/Kolkata" date +"%d-%b-%Y" | awk '{print toupper($0)}')
echo -e "\nCurrent Date: $REPORT_DATE"

echo -e "\nEnter Activities (end with CTRL+D):"
ACTIVITIES_RAW=$(</dev/stdin)
ACTIVITIES=$(echo "$ACTIVITIES_RAW" | escape_html | sed ':a;N;$!ba;s/\n/<br>/g')

echo -e "\nEnter Pending Works (end with CTRL+D):"
PENDING_RAW=$(</dev/stdin)
PENDING=$(echo "$PENDING_RAW" | escape_html | sed ':a;N;$!ba;s/\n/<br>/g')

# Compose HTML Table
EMAIL_SUBJECT="Shift Handover Report: $ENGINEER On $REPORT_DATE At $SHIFT Shift"
EMAIL_BODY=$(cat <<EOF
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    table {
      border-collapse: collapse;
      width: 100%;
    }
    th, td {
      border: 1px solid #000;
      padding: 10px;
      vertical-align: top;
      text-align: left;
    }
    th {
      background-color: #f2f2f2;
    }
    td pre {
      margin: 0;
      font-family: Arial, sans-serif;
      white-space: pre-wrap;
    }
  </style>
</head>
<body>
  <table>
    <tr><th colspan="4" style="font-size: 18px; text-align: center;">Shift Handover Report: $ENGINEER ON $REPORT_DATE $SHIFT Shift</th></tr>
    <tr><td><strong>Team</strong></td></td><td>$TEAM_NAME</td><td><strong>Report Date</strong></td><td>$REPORT_DATE</td></tr>
    <tr><td><strong>Engineer Name</strong></td><td>$ENGINEER</td><td><strong>Shift</strong></td><td>$SHIFT</td></tr>
    <tr><td><strong>Activities</strong></td><td colspan="3"><pre style="margin: 0;">$ACTIVITIES</pre></td></tr>
    <tr><td><strong>Pending Works</strong></td><td colspan="3"><pre style="margin: 0;">$PENDING</pre></td></tr>
  </table>
</body>
</html>
EOF
)

# Preview
#echo "Preview:"
#echo "$EMAIL_BODY" | lynx -stdin -dump

# Send
echo -e "\n"
read -p "Send this report to $EMAIL_TO? [y/N]: " CONFIRM
if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    #echo "$EMAIL_BODY" | mailx -a "Content-Type: text/html" -s from="No Reply <noreply@guidehouse.com>" -s "$EMAIL_SUBJECT" "$EMAIL_TO"
    (echo "To: $EMAIL_TO"; echo "From: No Reply <noreply@gmail.com>"; echo "Subject: $EMAIL_SUBJECT"; echo "MIME-Version: 1.0"; echo "Content-Type: text/html; charset=UTF-8"; echo; echo $EMAIL_BODY) | /usr/sbin/sendmail -t
    echo "✅ Report sent to $EMAIL_TO"
else
    echo "❌ Report not sent."
fi
