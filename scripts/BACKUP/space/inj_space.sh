#!/bin/bash
. ../set_global_vars.sh
set_global_vars;

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../y.sh; ../restore.sh ${g_ds_user_name};
if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 0; fi
tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
echo "START inj_space.sh" >test.log

base_url="http://localhost:8080/rest/private/bench/inject";
call_number=1; fromUser=0; toUser=199;
for prefix in {abc,bcd,cde,def,efg}; do
	
	../x.sh; sleep 30; grep "Server start" ${tomcat_log_file} >>test.log
		
	# CALL
	call_start=$(date +%s);
        curl -ujohn:gtn "${base_url}/space?number=1&fromUser=${fromUser}&toUser=${toUser}&userPrefix=${prefix}.user&spacePrefix=${prefix}s"
	call_end=$(date +%s);
	
        # REPORT
        call_label="SPACE ${call_number}";
        call_time_second=$(expr $call_end - $call_start ); call_time_hour=$( echo "scale=4; ( ${call_time_second} / 3600 )" | bc );
        call_command="curl -ujohn:gtn \"${base_url}/space?number=1&fromUser=${fromUser}&toUser=${toUser}&userPrefix=${prefix}.user&spacePrefix=${prefix}s\""
        call_goal="Create 200 spaces"
        ${g_scripts_dir}/report/report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

        # MEASURE
        ${g_scripts_dir}/measure/measure.sh ${call_label}

        # TEST
        cp ${tomcat_log_file} catalina.out_DATASET_INJ_${call_number}
	grep "space injected successfully" catalina.out_DATASET_INJ_${call_number} >>test.log
	echo "NUMBER_OF_SPACE=`grep "${prefix}s" catalina.out_DATASET_INJ_${call_number} | grep -c created` (200 is PERFECT)" >>test.log 
	echo "NUMBER_OF_EXCEPTION=`grep -c "Exception" catalina.out_DATASET_INJ_${call_number}`" >>test.log
	echo "TIME=${call_time_second} (second)" >>test.log

	fromUser=$(expr ${fromUser} + 1000 ) ; toUser=$(expr ${toUser} + 1000 ) ; #fromUser=1000, toUser=1199
	call_number=$(expr ${call_number} + 1 );

	../y.sh; sleep 30;
done
	
../backup.sh ${g_ds_ostd_space_name};
echo "COMPLETE inj_space.sh"
