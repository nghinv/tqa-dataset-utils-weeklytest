#!/bin/bash
bck=$1
trash=$(date +%Y%m%d-%H%M%S)
pushd ${g_shared_dir}
	if [ -d ${bck} ]; then mv ${bck} ${bck}_bck_${trash}; fi
	if [ -f ${bck}.zip ]; then mv ${bck}.zip ${bck}.zip_bck_${trash}; fi
	mkdir ${bck}; cp -r data ${bck}
	mysqldump -uroot -ptest_control --add-drop-database --opt --databases plf_jcr plf_idm >${bck}/plf_jcr_idm.sql
	zip -rq ${bck}.zip ${bck}
	
	cp ${bck}.zip ${g_store_dir}
popd
