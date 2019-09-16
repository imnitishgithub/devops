##########################################################################################################
# Created by Nitish Gupta 25-Jan-2019
# Requested by EMDS OAIMS for Auto code deployment
# This is a script to migrate table creation DDL (tab) files as part of the Auto code deployment process.
##########################################################################################################

#!/bin/ksh
#set -vx
cd /u05/jenkins/instances/eo-jenkins/jenkins_data/jobs/EMDS/oracle/instantclient_12_2
# Usage and Inputs
usage ()
{
printf "usage: migrate_tab.sh [TARGET_USER_NAME] [TARGET_ENV_NAME] [TAB_FILE_PATH] [TAB_FILE_NAME] "
printf "Check your inputs"
exit $1
}
close_process()
{
   DATE=`date +'%D %H:%M:%S'`
   echo "Execution completed at ${DATE}."
   echo "Execution completed at ${DATE}." >> ${LOGFILE}
   echo "******************************************************************************************************************"
   echo "******************************************************************************************************************" >> ${LOGFILE}
}

begin_process()
{
   DATE=`date +'%D %H:%M:%S'`
   echo "******************************************************************************************************************"
   echo "******************************************************************************************************************" > ${LOGFILE}
   echo "Starting ${FNAME} in ${DBNAME} at time ${DATE}..... "
   echo "Starting ${FNAME} in ${DBNAME} at time ${DATE}..... " >> ${LOGFILE}
}

if test $# -ne 4
then
        usage 1
else
        USR=$4
        echo $USR
        DBNAME=$1
        echo $DBNAME

        if [ "${DBNAME}" = "EMDSAD" ];
        then
        PWD="vNlsEjca5"
        fi

        if [ "${DBNAME}" = "EMDSAU" ];
        then
        PWD="mSxfFakq5"
        fi

        if [ "${DBNAME}" = "EMDSAS" ];
        then
        PWD="Ljiphpjl3"
        fi

        if [ "${DBNAME}" = "EMDSBD" ];
        then
        PWD="Idgcrfwz1"
        fi

        if [ "${DBNAME}" = "EMDSCD" ];
        then
        PWD="Kuujrtkv5"
        fi
        
        SPATH=$2
        echo $SPATH
        FNAME=$3
        echo $FNAME
        SPOOL_FILE=${FNAME}.spool
fi

#############################
# Env set-up
#############################
hstname=`hostname|awk -F"." '{print $1}'`
CMSH="/u05/jenkins/instances/eo-jenkins/jenkins_data/oaims_code_migration_scripts"
ORACLE_HOME="/u05/jenkins/instances/eo-jenkins/jenkins_data/jobs/EMDS/oracle/instantclient_12_2"
TNS_ADMIN="$ORACLE_HOME/network/admin/"
LD_LIBRARY_PATH="/u05/jenkins/instances/eo-jenkins/jenkins_data/jobs/EMDS/oracle/instantclient_12_2"
LOGFILE="/u05/jenkins/instances/eo-jenkins/jenkins_data/logfiles/${FNAME}.log"
export CMSH ORACLE_HOME TNS_ADMIN LD_LIBRARY_PATH
rm $LOGFILE
begin_process
#############################
# Input validation
#############################
# File extension check

valid_ext="sql"
if [[ $FNAME != *.${valid_ext} ]]
then
         echo "The File Extension is not valid (${valid_ext}). Check input filename  ${FNAME}"
         echo "The File Extension is not valid (${valid_ext}). Check input filename  ${FNAME}" >> ${LOGFILE}
         close_process
         exit 1
fi
# Make sure all Username value is uppercase
USR=$(echo ${USR}|tr 'a-z' 'A-Z')

###############################################
# Login to the database and running the script
###############################################
DB_CONNECT_STRING="$USR/$PWD@$DBNAME"
SCRIPT="$SPATH/$FNAME"
echo $SCRIPT
echo " CONNECTING TO THE DATABASE ..."
echo " CONNECTING TO THE DATABASE ..." >> ${LOGFILE}
echo "                               "
echo "                               "  >> ${LOGFILE}
echo "STARTING THE SCRIPT(s)......."
echo "STARTING THE SCRIPT(s)......."     >> ${LOGFILE}
./sqlplus -s "$DB_CONNECT_STRING" << EOF >> ${LOGFILE}
SET HEADING ON
SET FEEDBACK OFF
SET LINESIZE 3800
SET TRIMSPOOL ON
SET TERMOUT OFF
SET SPACE 0
SET PAGESIZE 0
SPOOL ${SPOOL_FILE}
@'$SCRIPT'
commit;
SPOOL OFF
exit;
EOF
cat ${SPOOL_FILE} >> ${LOGFILE}


###############################################
# ORA- Error Trapping
###############################################
ora_count=`grep 'ORA-' ${LOGFILE}|uniq|wc -l`
obj_exists_count=`grep 'ORA-00955' ${LOGFILE}|uniq|wc -l`
unique_constraint_voilation=`grep 'ORA-00001' ${LOGFILE}|uniq|wc -l`

if [ $ora_count -gt 3 ]
   then
   echo "There are ORA- errors. Check logfile ${LOGFILE}"
   echo "There are ORA- errors. Check logfile ${LOGFILE}" >> ${LOGFILE}
   cat ${rem_logfile}
   close_process
   exit 1
fi

if [ $obj_exists_count -gt 0 ]
then
   echo "There are ORA-955 errors. These are non fatal, hence marking as successful. Check logfile ${LOGFILE}"
   echo "There are ORA-955 errors. These are non fatal, hence marking as successful. Check logfile ${LOGFILE}" >> ${LOGFILE}
   cat ${rem_logfile}
   close_process
   exit 0
else
   echo "No ORA- errors in ${LOGFILE}"
   echo "No ORA- errors in ${LOGFILE}" >> ${LOGFILE}
   echo "LOG FILE OF THE DEPLOYMENT :"
   echo "                             "
   cat ${LOGFILE}
   echo "                            "
   echo "END OF THE LOG FILE"
close_process
   exit 0
fi

if [ $unique_constraint_voilation -gt 0 ]
then
echo "There are ORA-00001 errors.Check if same row values already exists in table.Marking as successful. Check logfile ${LOGFILE}"
echo "There are ORA-00001 errors.Check if same row values already exists in table.Marking as successful. Check logfile ${LOGFILE}" >> ${LOGFILE}
cat ${rem_logfile}
close_process
exit 0
fi
