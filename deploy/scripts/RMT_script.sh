#!/bin/ksh
##########################################################################################################
# Created by Nitish Gupta 29-Jan-2019
# Requested by EMDS OAIMS for Auto code deployment
# This is a script to run remote scripts as part of the Auto code deployment process.
##########################################################################################################

################################################################
#Name:  RMT_script.sh
#
#Function: executes remote script thru ssh to remote database.
#           used in Jenkins to alleviate the need for agents
#
################################################################
#set -x
SRV=""
USR="oracle"
PRMS=""
MDL=""
usage ()
{
print "usage: RMT_script.sh [-h] [-s Server] [-u Unix User] [-m or -z Path/Module ] [-p Parameters]"
print "where:   -h help, usage"
print "         -s Server Name"
print "         -u Unix User - default oracle"
print "         -m or -z Path and Module Name to be executed"
print "         -p Module parameters"
exit 1
}
if [[ $# -eq 0 ]]
then
   usage 1
fi
while getopts s:u:m:p: name
do
      case $name in
      s|S)    SRV=$OPTARG;
              ;;
      u|U)    USR=$OPTARG;
              ;;
      m|M)    MDL=$OPTARG;
              ;;
      z|Z)    MDL=$OPTARG;
              ;;
      p|-P)   PRMS=$OPTARG
              ;;
      \?)     usage
              return 1
              ;;
      esac
done
echo "***********************************************************"
echo "Beginning the Script Execution......                       "
echo "***********************************************************"
echo "Executiing  /usr/bin/ssh ${SRV} -l ${USR} ${MDL} ${PRMS}"
    /usr/bin/ssh -t ${SRV} -l ${USR} ${MDL} ${PRMS}
exit $?
