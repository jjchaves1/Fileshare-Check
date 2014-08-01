#!/bin/bash

#Simple Script to check the utilization of our fileshares
#Requires a CentOS 6.5 or newer system, or an updated version of sort

FILESHARES=`cat /sandbox/jchaves1/fileshares/FILESHARES`

#Assuming the FILESHARES file follows the following format on each line, with each field separated by a semicolon and NO SPACES:
#FILESHARE_NAME;WARNING_THRESHOLD;CRITICAL_THRESHOLD;WARNING_MAILING_LIST;CRITICAL_MAILING_LIST

for SHARE in $FILESHARES
 do
  #ARRAY=$(echo $SHARE | tr "," "\n")
  NAME=`echo "$SHARE" | awk -F';' '{print $1}'`
  echo "Name: $NAME"
  WARN=`echo "$SHARE" | awk -F';' '{print $2}'`
  echo "Warning Level: $WARN%"
  CRIT=`echo "$SHARE" | awk -F';' '{print $3}'`
  echo "Critical Level: $CRIT%"
  WARN_MAILING_LIST=`echo "$SHARE" | awk -F';' '{print $4}'`
  echo "Warning Level Mailing List: $WARN_MAILING_LIST"
  CRIT_MAILING_LIST=`echo "$SHARE" | awk -F';' '{print $5}'`
  echo "Critical Level Mailing List: $CRIT_MAILING_LIST"

  SHAREUTILIZATION=`df -Ph | grep $NAME --max-count=1 |tr -s ' '|cut -d" " -f5|sed s/%//`
  echo -e "Share Utilization: $SHAREUTILIZATION% \n"
  FROM_COLON=`echo -e "$NAME" | sed s/:/'\n'/ | tail -n 1`

  #MOUNTPOINT=`df -Ph | grep $NAME --max-count=1 |tr -s ' '|cut -d" " -f6`
  if [ $SHAREUTILIZATION -ge $WARN ] && [ $SHAREUTILIZATION -lt $CRIT ];
      then
        echo -e "Warning: Please Consider Cleaning up this fileshare: $NAME" | mail -s "$NAME utilization is $SHAREUTILIZATION%" $WARN_MAILING_LIST
  elif [ $SHAREUTILIZATION -ge $CRIT ];
      then
        REPORT=`du -h --max-depth=1 $FROM_COLON | sort -rh | head -n 11`
        echo -e "CRITICAL MESSAGE: Clean up this fileshare: $NAME \n\n$FROM_COLON Report:\n\n$REPORT\n" | mail -s "$NAME utilization is $SHAREUTILIZATION%" $CRIT_MAILING_LIST
  fi

 done

