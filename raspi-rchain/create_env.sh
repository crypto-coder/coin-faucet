#!/bin/sh



# Setup all environment variables
create_variable_if_missing () {

	# Make sure the /etc/bash.bashrc.local file exists
	if [ ! -f /etc/bash.bashrc.local ]; then
		touch /etc/bash.bashrc.local
	fi

	# Check for the variable that was passed in
	variable_name=$1
	variable_value=$2

	if [ -z ${!variable_name+x} ]; then

		# Check if the variable was added to /etc/bash.bashrc.local but was not sourced yet
		variable_search_count=$(grep -e "$variable_name" -c /etc/bash.bashrc.local)

		if [ $variable_search_count = 0 ]; then
			echo "export $variable_name=$variable_value" >> /etc/bash.bashrc.local
		fi
	fi
}

create_variable_if_missing M2_HOME "\$HOME/.m2"
create_variable_if_missing JAVA_OPTS "\"-Xms256m -Xmx512m\""
create_variable_if_missing SBT_OPTS "\"-Xms256m -Xmx512m\""
create_variable_if_missing CLASSPATH "\$M2_HOME/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar:\$M2_HOME/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT.jar:\$M2_HOME/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar:\$M2_HOME/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT.jar:\$HOME/.local/share/java/java-cup-11b.jar:\$HOME/.local/share/java/java-cup-11b-runtime.jar"




#export M2_HOME=/root/.m2
#export JAVA_OPTS="-Xms256m -Xmx512m"
#export SBT_OPTS="-Xms256m -Xmx512m"

#export CLASSPATH=/root/.m2/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar
#export CLASSPATH=$CLASSPATH:/root/.m2/repository/io/netty/netty-tcnative-boringssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-boringssl-static-2.0.15.Final-SNAPSHOT.jar
#export CLASSPATH=$CLASSPATH:/root/.m2/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT-linux-aarch_64.jar
#export CLASSPATH=$CLASSPATH:/root/.m2/repository/io/netty/netty-tcnative-openssl-static/2.0.15.Final-SNAPSHOT/netty-tcnative-openssl-static-2.0.15.Final-SNAPSHOT.jar
#export CLASSPATH=$CLASSPATH:/root/.local/share/java/java-cup-11b.jar
#export CLASSPATH=$CLASSPATH:/root/.local/share/java/java-cup-11b-runtime.jar
#export PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/bin:/usr/local/bin:/usr/bin:/bin:/usr/bin/X11:/usr/games:/coinFaucet/sandcastle-raspi-deploy/sbt/bin
