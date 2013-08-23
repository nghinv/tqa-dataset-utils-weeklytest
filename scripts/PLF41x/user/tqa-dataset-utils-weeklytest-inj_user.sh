#!/bin/bash
. ../tqa-dataset-utils-weeklytest-set_global_vars.sh
set_global_vars;

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/tqa-dataset-utils-weeklytest-TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../tqa-dataset-utils-weeklytest-stop-app.sh; ../tqa-dataset-utils-weeklytest-restore.sh ${g_ds_init_name};
if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 1; fi
../tqa-dataset-utils-weeklytest-start-app.sh; sleep 30; tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
grep "Server start" ${tomcat_log_file} >test.log
call_number=1;
	
	# CALL
	call_start=$(date +%s)
	expect -f ./ex_telnet.exp
	call_end=$(date +%s)
	
	# REPORT
	call_label="USER"
	call_time_second=$(expr ${call_end} - ${call_start} ); call_time_hour=$( echo "scale=4; (${call_time_second} / 3600 )" | bc );
	call_command="expect -f ./ex_telnet.exp"
	call_goal="Create 5000 users"
	${g_scripts_dir}/report/tqa-dataset-utils-weeklytest-report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

	# MEASURE
	${g_scripts_dir}/measure/tqa-dataset-utils-weeklytest-measure.sh ${call_label}
	
	# TEST
	cp ${tomcat_log_file} .
	grep "1000 users created" >>test.log
	echo "NUMBER_OF_USER=`grep -c "created user" catalina.out.DATASET_INJ` (5000 is PERFECT)" >>test.log
	echo "NUMBER_OF_EXCEPTION=`grep -c "Exception" catalina.out.DATASET_INJ`" >>test.log
	echo "TIME=${call_time_second} (second)" >>test.log

../tqa-dataset-utils-weeklytest-stop-app.sh; ../tqa-dataset-utils-weeklytest-backup.sh ${g_ds_ostd_user_name};
echo "COMPLETE inj_user.sh"
