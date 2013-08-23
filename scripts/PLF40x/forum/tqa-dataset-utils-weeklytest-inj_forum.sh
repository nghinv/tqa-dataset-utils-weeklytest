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

base_url="http://localhost:8080/rest/private/bench/inject"; call_start=$(date +%s)

# CALL
for c in {a,b,c,d,e,f,g,h,i,j}; do
        case ${c} in
        a) userPrefix=abc.user; userMin=0 ;;
        b) userPrefix=bcd.user; userMin=1000 ;;
        c) userPrefix=cde.user; userMin=2000 ;;
        d) userPrefix=def.user; userMin=3000 ;;
        e) userPrefix=efg.user; userMin=4000 ;;
        f) userPrefix=abc.user; userMin=0 ;;
        g) userPrefix=bcd.user; userMin=1000 ;;
        h) userPrefix=cde.user; userMin=2000 ;;
        i) userPrefix=def.user; userMin=3000 ;;
        j) userPrefix=efg.user; userMin=4000 ;;
        esac
	curl -ujohn:gtn "${base_url}/forumCategory?number=1&catPrefix=${c}Category"
	curl -ujohn:gtn "${base_url}/forumForum?number=10&catPrefix=${c}Category&toCat=0&forumPrefix=Forum-${c}"
	fromUser=${userMin}; toUser=$(expr ${userMin} + 9 );
	for f in {0..9}; do
		curl -ujohn:gtn "${base_url}/forumTopic?number=1&toForum=${f}&forumPrefix=Forum-${c}&topicPrefix=Topic-${c}&fromUser=${fromUser}&toUser=${toUser}&userPrefix=${userPrefix}"
	done
	fromUser=${userMin}; toUser=$(expr ${userMin} + 9 );
	for t in {0..99}; do
		echo "Progress : Category ${c}, Topic ${t}."
		curl -ujohn:gtn "${base_url}/forumPost?number=1&toTopic=${t}&topicPrefix=Topic-${c}&postPrefix=Post-${c}&fromUser=${fromUser}&toUser=${toUser}&userPrefix=${userPrefix}"
		fromUser=$(expr ${fromUser} + 10 ); toUser=$(expr ${toUser} + 10 );
	done
done
call_end=$(date +%s);

# REPORT
call_label="FORUM";
call_time_second=$(expr $call_end - $call_start ); call_time_hour=$( echo "scale=4; ( ${call_time_second} / 3600 )" | bc );
call_command="./inj_forum.sh"
call_goal="Create 10,000 posts"
${g_scripts_dir}/report/report.sh -l "${call_label}" -c "${call_command}" -g "${call_goal}" -t "${call_time_second}" -T "${call_time_hour}"

# MEASURE
${g_scripts_dir}/measure/measure.sh ${call_label}

# TEST
cp ${tomcat_log_file} .
echo "NUMBER_OF_SUCCESS_CURL=`grep -c "injecting data has been done successfully" catalina.out.DATASET_INJ` (1120 is PERFECT)" >>test.log 
echo "NUMBER_OF_EXCEPTION=`grep -c Exception catalina.out.DATASET_INJ`" >>test.log
echo "NUMBER_OF_POST=`grep Post catalina.out.DATASET_INJ | grep -c created` (10000 is PERFECT)" >>test.log
echo "TIME=${call_time_second} (second)" >>test.log

../y.sh; ../backup.sh ${g_ds_forum_name};
pushd ${g_shared_dir}; grep -o -E '\[\]topic[0-9a-zA-Z]+' ${g_ds_forum_name}/plf_jcr_idm.sql | sort >${g_ds_forum_name}.csv
sed -i 's/.*\(topic.*\)/forum\/topic,\1/g' ${g_ds_forum_name}.csv 
cp ${g_ds_forum_name}*.csv ${g_store_dir}
popd
echo "COMPLETE inj_forum.sh"
