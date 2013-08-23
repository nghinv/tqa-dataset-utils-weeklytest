#!/bin/bash
# Use : ../report/tqa-dataset-utils-weeklytest-report.sh -l call_label -c call_command -g call_goal -t call_time_ms -T call_time_hour -r call_result -e call_error -n call_note

label="";command="";goal="";time_second="";time_hour="";result="Success";error="";note="";
if [ -z ${g_report_dir} ]; then report_file=../report/progress.txt; else report_file=${g_report_dir}/report.txt; fi

while getopts l:c:g:t:T:r:e:n: option; do
	case $option in
	l) label=$OPTARG;;
	c) command=$OPTARG;;
	g) goal=$OPTARG;;
	t) time_second=$OPTARG;;
	T) time_hour=$OPTARG;;
	r) result=$OPTARG;;
	e) error=$OPTARG;;
	n) note=$OPTARG;;
	esac
done
report_line="|${label}|${command}|${goal}|${time_second}|${time_hour}|${result}|${error}|${note}";
echo "${report_line}" >> ${report_file};
