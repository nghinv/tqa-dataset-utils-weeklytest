#!/bin/bash
if [ -z ${g_measure_dir} ]; then 
        mysql_csv=./mysql.csv
        jcr_csv=./jcr.csv
else
        mysql_csv=${g_measure_dir}/mysql.csv
        jcr_csv=${g_measure_dir}/jcr.csv
fi
if [ -z ${g_shared_dir} ]; then
	values_dir=../../shared/data/jcr/values
	index_dir=../../shared/data/jcr/index
else
	values_dir=${g_shared_dir}/data/jcr/values
	index_dir=${g_shared_dir}/data/jcr/index
fi
echo "${mysql_csv} ${values_dir}"
echo "Measured after call $1 at `date`" >> ${mysql_csv}
echo "Measured after call $1 at `date`" >> ${jcr_csv}
mysql -uroot -ptest_control -e "select table_schema, table_name,table_rows, data_length, index_length from information_schema.tables where table_schema='plf_jcr' or table_schema='plf_idm'" >> ${mysql_csv}
du -sk ${values_dir} >> ${jcr_csv}
du -sk ${index_dir} >> ${jcr_csv}
