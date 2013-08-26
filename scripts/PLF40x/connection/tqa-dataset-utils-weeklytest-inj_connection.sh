#!/bin/bash
. ../tqa-dataset-utils-weeklytest-set_global_vars.sh
set_global_vars;

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/tqa-dataset-utils-weeklytest-TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../tqa-dataset-utils-weeklytest-stop-app.sh; # ../tqa-dataset-utils-weeklytest-restore.sh ${g_ds_membership_name};
# if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 0; fi
../tqa-dataset-utils-weeklytest-start-app.sh; sleep 30; tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
grep "Server start" ${tomcat_log_file} >test.log

base_url="http://localhost:8080/rest/private/bench/inject";
number=99; # number of connections per user.
call_number=1; fromUser=0; toUser=99;
for prefix in {abc,bcd,cde,def,efg}; do
        # CALL
        call_start=$(date +%s);
	for i in {1..10}; do
		curl -ujohn:gtn "${base_url}/relationship?number=${number}&fromUser=${fromUser}&toUser=${toUser}&prefix=${prefix}.user"
		fromUser=$(expr ${fromUser} + 100 ) ; toUser=$(expr ${toUser} + 100 ) ; #next call
	done
        call_end=$(date +%s);

        # REPORT
        call_label="CONNECTION ${call_number}";
        call_time_second=$(expr $call_end - $call_start ); call_time_hour=$( echo "scale=4; ( ${call_time_second} / 3600 )" | bc );
        call_command="Pseudo-code : curl -ujohn:gtn \"${base_url}/relationship?number=${number}&fromUser=x0&toUser=x999&prefix=${prefix}.user\""
        call_goal="Create full connections for ${prefix} users"
        ${g_scripts_dir}/report/tqa-dataset-utils-weeklytest-report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

        # MEASURE
        ${g_scripts_dir}/measure/tqa-dataset-utils-weeklytest-measure.sh ${call_label}
	
	call_number=$(expr ${call_number} + 1 );
done
# TEST
cp ${tomcat_log_file} .
echo "NUMBER_OF_EXCEPTION=`grep -c Exception catalina.out.DATASET_INJ`" >>test.log
echo "NUMBER_OF_SUCCESS_CURL=`grep -c "injecting data has been done successfully" catalina.out.DATASET_INJ` (50 is PERFECT)" >>test.log

../tqa-dataset-utils-weeklytest-stop-app.sh; ../tqa-dataset-utils-weeklytest-backup.sh ${g_ds_space_name};
pushd ${g_shared_dir}; cp ${g_ds_space_name}*.csv ${g_store_dir}; popd
echo "COMPLETE inj_connection.sh"
