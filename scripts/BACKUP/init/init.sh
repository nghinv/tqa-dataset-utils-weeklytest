#!/bin/bash
. ../set_global_vars.sh
set_global_vars;

# EMPTY DATA
../y.sh;
if [ -d ${g_shared_dir} ]; then rm -rf ${g_shared_dir}/data ; fi
mkdir ${g_shared_dir}/data
mysql -uroot -ptest_control -e "drop database plf_jcr; drop database plf_idm; create database plf_jcr; create database plf_idm;"

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../x.sh; sleep 30; tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
grep "Server start" ${tomcat_log_file}

# WAIT FOR FINISHING WELCOME-SCREEN MANUALLY
while true; do
	sleep 60
	if [ -f continue.continue.continue ]; then echo "continue!!!"; break
		else echo "waiting... Please create file continue.continue.continue (in init folder) after you finish welcome-screen!"
	fi
done
../y.sh; ../backup.sh ${g_ds_init_name};
echo "COMPLETE init.sh"
