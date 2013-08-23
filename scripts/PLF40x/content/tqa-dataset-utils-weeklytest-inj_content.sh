#!/bin/bash
. ../tqa-dataset-utils-weeklytest-set_global_vars.sh
set_global_vars;

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/tqa-dataset-utils-weeklytest-TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../tqa-dataset-utils-weeklytest-stop-app.sh; ../tqa-dataset-utils-weeklytest-restore.sh ${g_ds_user_name};
if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 0; fi
../tqa-dataset-utils-weeklytest-start-app.sh; sleep 30; tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
grep "Server start" ${tomcat_log_file} >test.log

# RUN jmeter script to set permission for /platform/users to see the content
${g_jmeter_bin_dir}/jmeter.sh -n -t "jmeter_content_set_permission_plf4.jmx" -l "jmeter_content_set_permission_plf4.jtl" 
echo "NUMBER_OF_SUCCESS_REQ=`grep -c ' s="true"' jmeter_content_set_permission_plf4.jtl`" >>test.log
echo "NUMBER_OF_FAIL_REQ=`grep -c ' s="false"' jmeter_content_set_permission_plf4.jtl`" >>test.log

call_number=1; base_url="http://localhost:8080/rest/private/contents/populate";
call_start=$(date +%s)
for folderPath in {A,B,C,D,E,F,G,H,I,J}; do

	echo "CALL ${folderPath} ${call_number} start : `date +%Y%m%d-%H%M%S`"
	
	# CALL
	curl -ujohn:gtn "${base_url}/storage?workspace=collaboration&folderPath=Dataset/${folderPath}&name=${folderPath}_&from=0&to=499&docType=doc&size=68"
	curl -ujohn:gtn "${base_url}/storage?workspace=collaboration&folderPath=Dataset/${folderPath}&name=${folderPath}_&from=0&to=499&docType=pdf&size=371"

	call_number=$(expr ${call_number} + 1 );
done
call_end=$(date +%s);
       
	# REPORT
	call_label="CONTENT";
	call_time_second=$(expr $call_end - $call_start ); call_time_hour=$( echo "scale=4; ( ${call_time_second} / 3600 )" | bc ); 
	call_command="Sample : curl -ujohn:gtn \"${base_url}/storage?workspace=collaboration&folderPath=Dataset/${folderPath}&name=${folderPath}_&from=0&to=499&docType=doc&size=68\""
	call_goal="Create 5000 .doc and 5000 .pdf of size 150KB"
	${g_scripts_dir}/report/tqa-dataset-utils-weeklytest-report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

	# MEASURE
	${g_scripts_dir}/measure/tqa-dataset-utils-weeklytest-measure.sh ${call_label}
	
	# TEST
	cp ${tomcat_log_file} .
	echo "NUMBER_OF_SUCCESS_CURL=`grep -c "Data Injector for ECMS finished successfully" catalina.out.DATASET_INJ` (20 is PERFECT)" >>test.log
	echo "NUMBER_OF_EXCEPTION=`grep -c Exception catalina.out.DATASET_INJ`" >>test.log
	echo "TIME=${call_time_second} (second)" >>test.log

../tqa-dataset-utils-weeklytest-stop-app.sh; ../tqa-dataset-utils-weeklytest-backup.sh ${g_ds_content_name};
pushd ${g_shared_dir}; cp ${g_ds_content_name}*.csv ${g_store_dir}; popd
echo "COMPLETE inj_content.sh"
