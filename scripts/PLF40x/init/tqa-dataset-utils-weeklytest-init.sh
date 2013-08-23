#!/bin/bash
current_dir=`dirname $0`
echo "`date`,current_dir=${current_dir}"
. ../tqa-dataset-utils-weeklytest-set_global_vars.sh
set_global_vars;

# EMPTY DATA
../tqa-dataset-utils-weeklytest-stop-app.sh;
if [ -d ${g_shared_dir} ]; then rm -rf ${g_shared_dir}/data ; fi
mkdir ${g_shared_dir}/data
mysql -uroot -ptest_control -e "drop database plf_jcr; drop database plf_idm; create database plf_jcr; create database plf_idm;"

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/tqa-dataset-utils-weeklytest-TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../tqa-dataset-utils-weeklytest-start-app.sh; sleep 30; tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
grep "Server start" ${tomcat_log_file}

echo "`date`,Init platform right after 1st deployment"
${g_jmeter_bin_dir}/jmeter.sh -n -t "${current_dir}/PLF_INIT.jmx" -l "${current_dir}/PLF_INIT.jmx.jtl" -Jexpinit_continue_file_path="${current_dir}/continue.continue.continue"
echo "`date`,Init platform right after 1st deployment, done"

while true; do
	sleep 60
	if [ -f continue.continue.continue ]; then echo "continue!!!"; break
		else echo "waiting... Please create file continue.continue.continue (in init folder) after you finish welcome-screen!"
	fi
done
../tqa-dataset-utils-weeklytest-stop-app.sh; ../tqa-dataset-utils-weeklytest-backup.sh ${g_ds_init_name};
echo "COMPLETE init.sh"
