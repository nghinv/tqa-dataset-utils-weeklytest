#!/bin/bash
function set_global_vars() {
export g_week_label=W32-20130807
export g_store_dir=/mnt/nfs4/DATASETS/PLF/PLF4_WEEKLY/${g_week_label}	# where (in mnt) the datasets are saved
export g_conf_file=DATASET_INJ					# prefix name of file _CURRENT_CONFIG
export g_ds_init_name=PLF4_INIT					# backup after setup account
export g_ds_ostd_user_name=PLF4_OSTD_5KU			# OSTD=outstanding - backup after user injection (and before login)
export g_ds_user_name=PLF4_5KU
export g_ds_forum_name=PLF4_5KU_10KPOST
export g_ds_wiki_name=PLF4_5KU_10KWIKI
export g_ds_calendar_name=PLF4_5KU_1YCAL
export g_ds_content_name=PLF4_5KU_10KDOC
export g_ds_ostd_space_name=PLF4_5KU_OSTD_SPACE			# backup after injecting spaces (before membership)
export g_ds_membership_name=PLF4_5KU_MEMBERSHIP			# backup after membership injection (before connection)
export g_ds_space_name=PLF4_5KU_1KSPACE

export g_working_root_dir=/java/exo-working/DATASET_WORK/dataset-weekly-plf4
export g_tomcat_dir=${g_working_root_dir}/pkg/${g_week_label}/tomcat-bundle 
export g_shared_dir=${g_working_root_dir}/shared
export g_scripts_dir=/mnt/nfs4/DATASETS/PLF/PLF4_WEEKLY/scripts/PLF40x

export g_pkg_source=/mnt/nfs4/others/packages/PLF402/plf-enterprise-tomcat-standalone-4.0.2.zip

export g_pkg_commons=/mnt/nfs4/DATASETS/PLF/PLF4_WEEKLY/scripts/PLF40x/commons

export g_jmeter_bin_dir=/home/qahudson/testsuite/tools/jmeter-2.7/bin		# where jmeter.sh is located
export g_jmeter_jmx_dir=${g_scripts_dir}/jmeter					# where common jmeter script (if any) is located
export g_jmeter_csv_dir=${g_scripts_dir}/jmeter/csv				# where common jmeter csv (if any) is located

export g_report_dir=${g_scripts_dir}/report
export g_measure_dir=${g_scripts_dir}/measure

export g_host=localhost
}
