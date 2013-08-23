#!/bin/sh
#CATALINA_OPTS="$CATALINA_OPTS -Xms${EXO_JVM_SIZE_MIN} -Xmx${EXO_JVM_SIZE_MAX} -XX:MaxPermSize=${EXO_JVM_PERMSIZE_MAX}"
CATALINA_OPTS="${CATALINA_OPTS}  -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=./ -Xms3g -Xmx5g -XX:MaxPermSize=512m -XX:+UseConcMarkSweepGC -XX:+UseCompressedOops -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.port=8004 -Dcom.sun.management.jmxremote.authenticate=false "


