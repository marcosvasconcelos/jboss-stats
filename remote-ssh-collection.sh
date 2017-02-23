#/bin/sh
#####################################################################################################
##
##      @Author: Marcos Vasconcelos
##      @email: marcos.vasconcelos@hpe.com
##      @Version: 1.0
##      @Description: Script for collect remote statistics in JBoss EAP environment from SSH service
##
##
#####################################################################################################
#####################################################################################################
#####################################################################################################

DIRNAME=`dirname "$0"`
cd $DIRNAME
DATE=`date +"%Y-%m-%d"`
PROPERTY_FILE=conf/remote-collect.props

getProperty() {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE

}


getRemoteStatsSSH(){

	userName=$(getProperty 'userName')
	SRV_ADDR_PROP=$(getProperty 'SRV_ADDR')
	LOG_PATH=$(getProperty 'LOG_PATH')
	
	
	for SRV_ADDR in $(echo $SRV_ADDR_PROP | sed "s/,/ /g")
	do

		#GET_REMOTE_JBOSS_STATS_DATASOURCES=`ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep datasources`
		ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep datasources >> $LOG_PATH/datasources-$DATE.json
		#echo $GET_REMOTE_JBOSS_STATS_DATASOURCES >> $LOG_PATH/datasources-$DATE.json

		#GET_REMOTE_JBOSS_STATS_MEMORY=`ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep jvm-memory`
		ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep jvm-memory >> $LOG_PATH/memory-$DATE.json

		#echo $GET_REMOTE_JBOSS_STATS_MEMORY >> $LOG_PATH/memory-$DATE.json
		
		#GET_REMOTE_JBOSS_STATS_WORKMANAGERS=`ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep workmanagers`
		ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep workmanagers >> $LOG_PATH/workmanagers-$DATE.json
		#echo $GET_REMOTE_JBOSS_STATS_WORKMANAGERS >> $LOG_PATH/workmanagers-$DATE.json

		#GET_REMOTE_JBOSS_STATS_THREADS=`ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep threading`
		ssh $userName@$SRV_ADDR '(sudo -u admweb  /app/scripts/jboss-stats/jboss-stats-remote.sh)' | grep threading >> $LOG_PATH/threading-$DATE.json
		
		#echo $GET_REMOTE_JBOSS_STATS_THREADS >> $LOG_PATH/threading-$DATE.json
		
		
	done
}

getRemoteStatsSSH
