#!/bin/bash
source ../set_global_vars.sh
set_global_vars

if [ ! -f ${g_pkg_source} ]; then echo "Check pkg zip file then Retry! EXIT!!!"; exit 1; fi
if [ -d ${g_working_root_dir}/pkg/${g_week_label} ]; then
	rm -rf ${g_working_root_dir}/pkg/${g_week_label}/*
	else
	mkdir ${g_working_root_dir}/pkg/${g_week_label}
fi

pushd ${g_working_root_dir}/pkg/${g_week_label}
	sg_string="s/.*\/\([^/]\)/\1/g"
	link_name=`echo "${g_pkg_source}" | sed ${sg_string}`
	ln -s ${g_pkg_source} ${link_name}
	
	sg_string="s/.* \([^ ]*\)\/bin\//\1/g"
	bin_upper_dir=$( unzip -l ${link_name} | grep -m 1 /bin/ | sed "${sg_string}" )
	echo $bin_upper_dir
	unzip -q ${link_name} ; if [ ! -d tomcat-bundle ]; then mv ${bin_upper_dir} tomcat-bundle; fi
popd

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
cp -v john.xml ${g_working_root_dir}/pkg/${g_week_label}/tomcat-bundle
cp -rv --suffix=.origin ${g_pkg_commons}/webapps/../* ${g_working_root_dir}/pkg/${g_week_label}/tomcat-bundle
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
pushd ${g_working_root_dir}/pkg/${g_week_label}/tomcat-bundle/webapps;

	unzip -q platform-extension.war -d platform-extension; mv platform-extension.war platform-extension.war.origin
	pushd platform-extension/WEB-INF/conf/organization/
		mv organization-configuration.xml organization-configuration.xml.origin
		n=$( grep -n -m 1 exo.super.user organization-configuration.xml.origin | sed 's/\([^:]\):.*/\1/g' )
		if [ -z $n ]; then echo "platform-extension.war : FAILURE"; fi
		n=$(( n + 1 ));
		m=$( tail -n +$n organization-configuration.xml.origin | grep -n -m 1 "</value>" | sed 's/\([^:]\):.*/\1/g' )
		if [ -z $m ]; then echo "platform-extension.war : FAILURE"; fi
		n=$(expr $n + $m - 1 );
		head -$n organization-configuration.xml.origin >organization-configuration.xml
		cat ${g_working_root_dir}/pkg/${g_week_label}/tomcat-bundle/john.xml >>organization-configuration.xml
		n=$(( n + 1 ))
		tail -n +$n organization-configuration.xml.origin >>organization-configuration.xml
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
		diff organization-configuration.xml.origin organization-configuration.xml	
		echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
	popd
	cd platform-extension; zip -rq ../platform-extension.war * ; cd ..; rm -rf platform-extension;
popd
