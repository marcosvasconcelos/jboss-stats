#!/bin/bash
######
########
##
##      @Author: Marcos Vasconcelos
##      @email: marcos.vasconcelos@hpe.com
##      @Version: 1.0
##      @Description: Script to criptograph user / password and configure crontab
##
##
############################################################
############################################################
############################################################

DIRPATH=`pwd`
cd $DIRPATH
JB_STATS_HOME=$DIRPATH

DAY_W="*"
DAY_M="*"
MONTH="*"
HOUR="*"
MIN="*/3"

#### Configure Crontab from SHELL
#################################
crontabConfig()
{

        #### wirte definitions out of actual crontab
        #############################
        clear
		echo ""
        echo "########################################################################################################"
        echo "########################################################################################################"
        echo "########################################################################################################"
        echo ""
        echo "--------------------------------------- MIN  HOUR  DAY_M  MONTH  DAY_W -----------------------------"
        echo "To schedule a new crontab, use: insert $MIN $MONTH $DAY_M $MONTH $DAY_W such as crontab confguration."
        echo "WARNING ################################### WARNING ############################################ WARNING"
        echo "Is strongly recommended not use less than 3 minutes '('*/3')' between each execution."
		echo ""
        echo "########################################################################################################"
        echo "########################################################################################################"
		echo "########################################################################################################"
        read CRONTAB_CONF
        crontab -l > jbossstats
        echo "$CRONTAB_CONF /bin/sh $JB_STATS_HOME/jboss-stats.sh 2>&1 $JB_STATS_HOME/logs/jboss-stats.log&" >> jbossstats
        #install new cron file
        crontab jbossstats
        rm jbossstats
}

cryptoUser()
{
	#### Criptograph user and password to connect in jboss instance
        #############################
        clear
                echo ""
        echo "########################################################################################################"
        echo "########################################################################################################"
        echo "########################################################################################################"
        echo "Insert username and password to connect in jboss instance."
        echo "User and password will be encrypted and used by jboss-stats"
        echo "########################################################################################################"
        echo "########################################################################################################"
        echo "########################################################################################################"
	echo "Please insert username:"
        read userNameInput
	usernameCrypto=`echo $userNameInput | openssl enc -aes-128-cbc -a -salt -pass pass:jbossWebMonitor`
	userName="userName:"$usernameCrypto
	echo "Please insert password:"
	read -s userPasswordInput
	userPasswordCrypto=`echo $userPasswordInput | openssl enc -aes-128-cbc -a -salt -pass pass:jbossWebMonitor`
	userPassword="userPassword:"$userPasswordCrypto
	echo "Username: $userName  and Password: $userPassword were inputed in conf/user.props"
	echo $userName > conf/user.props
	echo $userPassword >> conf/user.props

}

clear
echo ""
echo "########################################################################################################"
echo "########################################################################################################"
echo "########################################################################################################"
echo ""
echo "Usage: {crypto|crontab|help}"
echo ""
echo "--------------------------------------- MIN  HOUR  DAY_M  MONTH  DAY_W -----------------------------"
echo "To schedule a new crontab, use: insert $MIN $MONTH $DAY_M $MONTH $DAY_W such as crontab confguration."
echo "Is not necessary insert execution command."
echo "To crypto username and password for connect to jboss instance."
echo ""
echo "########################################################################################################"
echo "########################################################################################################"
echo "########################################################################################################"
echo ""
read jbossstats
case "$jbossstats" in
        crontab)
            crontabConfig
            ;;

        crypto)
            cryptoUser
            ;;
        *)
            exit 1

esac

