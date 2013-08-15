#!/bin/bash
. ../set_global_vars.sh
set_global_vars;

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../y.sh; ../restore.sh ${g_ds_ostd_user_name};
if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 0; fi
tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
echo "START login_n_backup.sh" >test.log

for call_number in {1..5}; do
	
	../x.sh; sleep 30; grep "Server start" ${tomcat_log_file} >>test.log

	# CALL
	call_start=$(date +%s)
	${g_jmeter_bin_dir}/jmeter.sh -n -t "PLF4_TQA-979_TEST_5KU_LOGIN.jmx" -l "call_${call_number}.jtl" -JexpCsvDatasetFolder=. -JexpUserDatasetName=DS_PLF4_W11_WEEKLY_USERS_1000_${call_number}U.csv
	call_end=$(date +%s)
	
	# REPORT
	call_label="LOGIN ${call_number}"
	call_time_second=$(expr ${call_end} - ${call_start} ); call_time_hour=$( echo "scale=4; (${call_time_second} / 3600 )" | bc );
	call_command="${g_jmeter_bin_dir}/jmeter.sh -n -t \"PLF4_TQA-979_TEST_5KU_LOGIN.jmx\" -l \"call_${call_number}.jtl\" -JexpCsvDatasetFolder=. -JexpUserDatasetName=DS_PLF4_W11_WEEKLY_USERS_1000_${call_number}U.csv"
	call_goal="Login 1000 users"
	${g_scripts_dir}/report/report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"
	
	# MEASURE
	${g_scripts_dir}/measure/measure.sh ${call_label}

	# TEST
	cp ${tomcat_log_file} catalina.out.DATASET_INJ_${call_number}
	echo "NUMBER_OF_LOGIN=`grep -c "logged in" catalina.out.DATASET_INJ_${call_number}` (1000 is PERFECT)" >>test.log
	echo "NUMBER_OF_EXCEPTION=`grep -c "Exception" catalina.out.DATASET_INJ_${call_number}`" >>test.log
	echo "NUMBER_OF_SUCCESS_REQUEST=`grep -c ' s="true"' call_${call_number}.jtl` (9000 is PERFECT)" >>test.log
	echo "DURATION=${call_time_second} (second)" >>test.log
	
	../y.sh;
done

../backup.sh ${g_ds_user_name};
pushd ${g_shared_dir}; cp ${g_ds_user_name}*.csv ${g_store_dir}; popd
echo "COMPLETE login_n_backup.sh"
