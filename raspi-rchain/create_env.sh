#!/bin/sh





export M2_HOME=/root/.m2
export JAVA_OPTS="-Xms256m -Xmx512m"
export SBT_OPTS="-Xms256m -Xmx512m"

export CLASSPATH=/root/.m2/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar
export CLASSPATH=$CLASSPATH:/root/.m2/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT.jar
export CLASSPATH=$CLASSPATH:/root/.m2/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar
export CLASSPATH=$CLASSPATH:/root/.m2/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT.jar
export CLASSPATH=$CLASSPATH:/root/.local/share/java/java-cup-11b.jar
export CLASSPATH=$CLASSPATH:/root/.local/share/java/java-cup-11b-runtime.jar
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games:/coinFaucet/sandcastle-raspi-deploy/sbt/bin
