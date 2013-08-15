#!/bin/bash
. ../set_global_vars.sh
set_global_vars;

CONFIG_FILE=/home/qahudson/testsuite/${g_conf_file}_`hostname`_CURRENT_CONFIG
config_line="${g_tomcat_dir} NO_RESTORE plf_jcr plf_idm!DATASET_INJ 1 10 3600 9999 ${g_host} 8080 DATASET true true - - WEEKLY_INJ - /home/qahudson/testsuite/props/TEST_INJ.properties!eXoPLF.install.sh"
echo ${config_line} >${CONFIG_FILE}

../y.sh; ../restore.sh ${g_ds_user_name};
if [ $? -eq 0 ]; then echo "EXIT due to restore failure"; exit 0; fi
../x.sh; sleep 30; tomcat_log_file=${g_tomcat_dir}/logs/catalina.out.DATASET_INJ
grep "Server start" ${tomcat_log_file} >test.log

base_url="http://localhost:8080/rest/private/bench/inject";

# PUBLIC WIKI (1110 pages)
call_number=1;
	# CALL
        call_start=$(date +%s);
        curl -ujohn:gtn "${base_url}/WikiDataInjector?type=data&q=10,10,100&pre=Public%20Wiki%20A,Public%20Wiki%20AB,Public%20Wiki%20ABC&wo=intranet&wt=portal"
        call_end=$(date +%s);

        # REPORT
        call_label="WIKI";
        call_time_second=$(expr $call_end - $call_start ); call_time_hour=$( echo "scale=4; ( ${call_time_second} / 3600 )" | bc );
        call_command="curl -ujohn:gtn \"${base_url}/WikiDataInjector?type=data&q=10,10,100&pre=Public%20Wiki%20A,Public%20Wiki%20AB,Public%20Wiki%20ABC&wo=intranet&wt=portal\""
        call_goal="Create 10110 WIKI (public) pages"
        ${g_scripts_dir}/report/report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

        # MEASURE
        ${g_scripts_dir}/measure/measure.sh ${call_label}
	
	# TEST
	cp ${tomcat_log_file} .
	grep "Injecting data has been done successfully" catalina.out.DATASET_INJ >>test.log
	echo "NUMBER_OF_EXCEPTION=`grep -c Exception catalina.out.DATASET_INJ`" >>test.log
	echo "NUMBER_OF_PAGE=`grep -c "Process page" catalina.out.DATASET_INJ` (10110 is PERFECT)" >>test.log
	echo "TIME=${call_time_second} (second)" >>test.log
	
../y.sh; ../backup.sh ${g_ds_wiki_name};
pushd ${g_shared_dir}; cp ${g_ds_wiki_name}*.csv ${g_store_dir}; popd
echo "COMPLETE inj_wiki.sh"
