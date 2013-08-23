#!/bin/bash
bck=$1;
pushd ${g_shared_dir};
	if [ ! -d ${bck} ]; then 
		if [ -f ${bck}.zip ]; then unzip -q ${bck}.zip;
		else popd; exit 0;
		fi
	fi
	rm -rf data; cp -r ${bck}/data .
	mysql -uroot -ptest_control <${bck}/plf_jcr_idm.sql;
popd;
exit 1
