#/bin/sh
#
#
##########

DIRNAME=`dirname "$0"`
cd $DIRNAME
DATE=`date +"%Y-%m-%d"`
PROPERTY_FILE=conf/server.props
USER_FILE=conf/user.props

getProperty() {
   PROP_KEY=$1
   PROP_VALUE=`cat $PROPERTY_FILE | grep "$PROP_KEY" | cut -d'=' -f2`
   echo $PROP_VALUE

}

getUserProperty() {
   USER_KEY=$1
   USER_VALUE=`cat $USER_FILE| grep "$USER_KEY" |cut -d':' -f2`
   echo $USER_VALUE

}

#### Get JBOSS STATS #####

getJBossEAPStats() {
	
	userName=`echo $(getUserProperty 'userName') | openssl enc -aes-128-cbc -a -d -salt -pass pass:jbossWebMonitor`
	userPassword=`echo $(getUserProperty 'userPassword') | openssl enc -aes-128-cbc -a -d -salt -pass pass:jbossWebMonitor`
	SRV_URL_PROP=$(getProperty 'INST_URL')
	DATA_SOURCE_PROP=$(getProperty 'DSNAME')
	LOG_PATH=$(getProperty 'LOG_PATH')
	echo $USER_NAME
	echo $USER_PASS
	for URL_SRV in $(echo $SRV_URL_PROP | sed "s/,/ /g")
	do
		#### DEF_NODE_NAME ####
		echo "Reading server instance name" >> logs/jboss-stats.log
		NODE_NAME=`curl --digest -D - "http://$userName:$userPassword@$URL_SRV/management/" -d '{"operation":"read-attribute", "include-runtime":"true", "address":[{"core-service":"server-environment"}],"name":"node-name"}' -HContent-Type:application/json | grep "{" | sed s/result/node-name/g | cut -f 2 -d "," | sed s/"}"//g`

        	#### WorkManagers JBoss ####
		echo "Reading workmanager stats">> logs/jboss-stats.log
		WORKMANAGER_CURL=`curl --digest -D - "http://$userName:$userPassword@$URL_SRV/management/" -d '{"operation":"read-resource","address":[{"subsystem":"jca"},{"workmanager":"default"},{"statistics":"local"}],"include-runtime":"true"}' -HContent-Type:application/json | grep "{"`

		WORKMANAGER=`echo $WORKMANAGER_CURL | sed s/": {"/": { $NODE_NAME, "/g`
		echo $WORKMANAGER >> $LOG_PATH/workmanager-$DATE.json
		
		#### Memory #########
		echo "Reading memory stats">> logs/jboss-stats.log
		MEMORY_CURL=`curl --digest -D - "http://$userName:$userPassword@$URL_SRV/management/" -d '{"operation":"read-resource", "include-runtime":"true", "address":[{"core-service":"platform-mbean"},{"type":"memory"}]}' -HContent-Type:application/json | grep "{"`

		MEMORY=`echo $MEMORY_CURL | sed s/": {"/": { $NODE_NAME, "/g`
		echo $MEMORY >> $LOG_PATH/memory-$DATE.json
		
		#### Threads ########
		echo "Reading Threads stats" >> logs/jboss-stats.log
		THREADS_CURL=`curl --digest -D - "http://$userName:$userPassword@$URL_SRV/management/" -d '{"operation":"read-resource", "include-runtime":"true", "address":[{"core-service":"platform-mbean"},{"type":"threading"}],"include-runtime":"true"}' -HContent-Type:application/json | grep "{"`

		THREADS_C=`echo $THREADS_CURL | sed s/'"all-thread-ids'.*'\], '//g | sed s/', "object-name" : "java.lang:type=Threading"'//g`
		THREADS=`echo $THREADS_C | sed s/": {"/": { $NODE_NAME, "/g`
		echo $THREADS >> $LOG_PATH/threads-$DATE.json
		for DS_NAME in $(echo $DATA_SOURCE_PROP | sed "s/,/ /g")
		do
			#### DataSource ########
			echo "Reading datasource stats for $DS_NAME" >> logs/jboss-stats.log
			DATA_SOURCE_CURL=`curl --digest -D - "http://$userName:$userPassword@$URL_SRV/management/" -d '{"operation":"read-resource","address":[{"subsystem":"datasources"},{"data-source":"'$DS_NAME'"},{"statistics":"pool"}],"include-runtime":"true"}' -HContent-Type:application/json | grep "success"`
			
			if [ ! -z "$DATA_SOURCE_CURL" ]
			then
 
				DATA_SOURCE=`echo $DATA_SOURCE_CURL | sed s/": {"/": { $NODE_NAME, "/g`
				echo $DATA_SOURCE=  >> $LOG_PATH/datasource-$DATE.json
			else
				echo "DataSource $DS_NAME not fount at $URL_SRV" >> logs/jboss-stats.log
			fi
		
		done 
	done
	
} 

echo "Reading jboss statistics"

getJBossEAPStats

