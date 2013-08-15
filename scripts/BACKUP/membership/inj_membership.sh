#!/bin/bash
. ../set_global_vars.sh
set_global_vars;

#CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
#config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/TEST_INJ.properties!eXoPLF.install.sh"
#echo ${config_line} >${CONFIG_FILE}

#../y.sh; # ../restore.sh ${g_ds_ostd_space_name};
# if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 0; fi
#tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
#echo "START inj_membership.sh" >test.log

base_url="http://localhost:8080/rest/private/bench/inject";
call_number=1;
for prefix in {abc,bcd,cde,def,efg}; do
	case ${prefix} in
	abc) fromUser=100; toUser=$(expr ${fromUser} + 199 ); fromSpace=100; toSpace=$(expr ${fromSpace} + 199 );;
	
	esac
	
	for i in {1,2,3,4}; do
	../x.sh; sleep 30; grep "Server start" ${tomcat_log_file} >>test.log
	# CALL
	call_start=$(date +%s);
        curl -ujohn:gtn "${base_url}/membership?type=member&fromUser=${fromUser}&toUser=${toUser}&userPrefix=${prefix}.user&fromSpace=${fromSpace}&toSpace=${toSpace}&spacePrefix=${prefix}s"
        call_end=$(date +%s);

        # REPORT
        call_label="MEMBERSHIP ${call_number}";
        call_time_second=$(expr $call_end - $call_start ); call_time_hour=$( echo "scale=4; ( ${call_time_second} / 3600 )" | bc );
        call_command="curl -ujohn:gtn \"${base_url}/membership?type=member&fromUser=${fromUser}&toUser=${toUser}&userPrefix=${prefix}.user&fromSpace=${fromSpace}&toSpace=${toSpace}&spacePrefix=${prefix}s\""
        call_goal="Add 2500 memberships"
        ${g_scripts_dir}/report/report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

        # MEASURE
        ${g_scripts_dir}/measure/measure.sh ${call_label}
	
	# TEST
	cp ${tomcat_log_file} catalina.out.DATASET_INJ_${call_number}
        echo "NUMBER_OF_SUCCESS_CURL=`grep -c "injecting data has been done successfully" catalina.out.DATASET_INJ_${call_number}`" >>test.log
	echo "NUMBER_OF_EXCEPTION=`grep -c Exception catalina.out.DATASET_INJ_${call_number}`" >>test.log
	echo "TIME=${call_time_second} (second)" >>test.log
	
	../y.sh;

	call_number=$(expr ${call_number} + 1 );
	fromUser=$(expr ${fromUser} + 100 ); toUser=$(expr ${fromUser} + 99 ); fromSpace=$(expr ${fromSpace} + 100 ); toSpace=$(expr ${fromSpace} + 99 );
	done
done
../backup.sh ${g_ds_membership_name};
echo "COMPLETE inj_membership.sh"
