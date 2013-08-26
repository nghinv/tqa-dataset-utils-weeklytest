#!/bin/bash
function restart_mysql()
{
  mysql_command_restart="sudo service mysql restart"
  echo " ++ `date` restarting mysql server ++"
  ${mysql_command_restart}
  kill -9 `ps aux | grep /usr/sbin/mysqld | awk '{ print $2 }'`
  ${mysql_command_restart}
  accu_time=0
  while true; do
      accu_time=$((accu_time + 2))
      if [ ${accu_time} -gt 3600 ]; then
	      echo "MySQL failed to startup"
	      exit 1
      fi
      grepcount=`mysqladmin -uroot -ptest_control  variable | grep -c hostname`
      if [ ${grepcount} -gt 0 ]; then
	    break;
      else
	    sleep 2
      fi
  done

  #mysql -uroot -ptest_control -e "$grant"

  #system_information
  echo " -- `date` restarting mysql server --"
  
}

echo "`date`, going to stop the application "
pushd /home/qahudson/testsuite && bash ./jmeter-utils-testcontroller.sh STOP_APPLICATION "${g_conf_file}_`hostname`"
echo "`date`, going to [restart the mysql server]"

restart_mysql

echo "`date`, done for [restart the mysql server]"
popd
