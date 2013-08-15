#!/bin/sh
#
# Copyright (C) 2009 eXo Platform SAS.
# 
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of
# the License, or (at your option) any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.
#

#Production Script to launch GateIn
#See gatein-dev.sh for development starup

# Computes the absolute path of eXo
cd `dirname "$0"`

# Sets some variables
#LOG_OPTS="-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.SimpleLog"
#SECURITY_OPTS="-Djava.security.auth.login.config=../conf/jaas.conf"
#TARGET_JMX_PORT=${TARGET_JMX_PORT:-"8004"}
#EXO_OPTS="-Dexo.product.developing=false -Dexo.conf.dir.name=gatein/conf -Dexo.jcr.session.tracking.active=false -Dexo.jcr.jcr.session.tracking.maxage=1200 -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=${TARGET_JMX_PORT} -Dcom.sun.management.jmxremote.authenticate=false $EXO_OPTS"
#if [ "$EXO_PROFILES" = "" ] ; then 
#	EXO_PROFILES="-Dexo.profiles=default"
#fi


#JAVA_OPTS="$JAVA_OPTS $LOG_OPTS $SECURITY_OPTS $EXO_OPTS $EXO_PROFILES -Xms4g -Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+UseConcMarkSweepGC -XX:HeapDumpPath=./ "
#export JAVA_OPTS

CATALINA_OPTS="-agentpath:/home/qahudson/jprofiler6/bin/linux-x64/libjprofilerti.so=offline,id=110,config=/home/qahudson/jprofiler6/configfolderforoffline/config.xml $CATALINA_OPTS -Xms4g -Xmx4g -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -XX:+UseConcMarkSweepGC -XX:HeapDumpPath=./ "
export CATALINA_OPTS

# Launches the server
#exec "$PRGDIR"./catalina.sh "$@"
cd ..
./start_eXo.sh
