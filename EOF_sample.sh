#!/bin/bash
ssh username@ip 'bash -s' << EOF
 vardate="Hello World"
 echo \$vardate
 varcmd=\$(ls)
 echo \$varcmd
 hostname
EOF
