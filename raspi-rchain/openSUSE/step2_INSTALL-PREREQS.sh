


# Install dependencies
zypper install -y automake cmake libapr1 libapr-util1 libapr-util1-devel ninja gcc gcc-c++ lmdb-devel openssl libopenssl1_0_0 libopenssl-devel libtool gnutls libgnutls-devel libgnutls-openssl-devel go1.9 java-1_8_0-openjdk-devel llvm jflex alex happy
zypper addrepo https://download.opensuse.org/repositories/devel:/languages:/haskell/openSUSE_Leap_42.3/devel:languages:haskell.repo | echo 'a'
zypper refresh
zypper install -y cabal-install

# Get libsodium
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue https://download.libsodium.org/libsodium/releases/libsodium-1.0.16.tar.gz
tar xf libsodium-1.0.16.tar.gz

# Build and install libsodium
cd libsodium-1.0.16
./configure
make && make check
sudo make install
cd ..

# Get LibreSSL
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue http://openbsd.cs.toronto.edu/pub/OpenBSD/LibreSSL/libressl-2.8.0.tar.gz
tar xf libressl-2.8.0.tar.gz

# Build and install LibreSSL
cd libressl-2.8.0
./configure
make
sudo make install
cd ..

# Get netty-tcnative (Tomcat Native)
git clone https://github.com/netty/netty-tcnative.git

# Build and install netty-tcnative (Tomcat Native)
export MAVEN_OPTS="-Xmx768m"
cd netty-tcnative
#./mvnw compile
sudo ./mvnw install
NETTY_VERSION=$(grep -e Final-SNAPSHOT pom.xml | sed 's/<version>//' | sed 's/<\/version>//' | sed 's/[ ]*//')
cd ..

# Download and Install Java CUP 11b
mkdir -p ~/.local/share/java/
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue http://central.maven.org/maven2/com/github/vbmacher/java-cup/11b/java-cup-11b.jar
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue http://central.maven.org/maven2/nz/ac/waikato/cms/weka/thirdparty/java-cup-11b-runtime/2015.03.26/java-cup-11b-runtime-2015.03.26.jar
cp java-cup-11b.jar ~/.local/share/java/
cp java-cup-11b-runtime-2015.03.26.jar ~/.local/share/java/java-cup-11b-runtime.jar

# Download and install Scala Build Tools
if [ ! -d "$(pwd)/sbt" ]; then
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue https://piccolo.link/sbt-1.2.1.zip
    unzip sbt-1.2.1.zip
	ln -s "$(pwd)/sbt/bin/sbt" /usr/local/bin/sbt
fi

# Download and install Haskell Tool Stack
#curl -sSL https://get.haskellstack.org/ | sh  
#sed -i "s/{}/{ system-ghc: true }/g" ~/.stack/config.yaml

# Download and install Glasgow Haskell Compiler
wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue https://downloads.haskell.org/~ghc/8.4.1/ghc-8.4.1-aarch64-deb8-linux.tar.xz
tar xf ghc-8.4.1-aarch64-deb8-linux.tar.xz
cd ghc-8.4.1
./configure
make install
cd ..

# Download and compile BNFC
if [ ! -d "$(pwd)/bnfc" ]; then
    git clone https://github.com/BNFC/bnfc
    cd bnfc/source
    cabal install
    ln -s "$(pwd)/dist/build/bnfc/bnfc" /usr/local/bin/bnfc
    cd ../..
fi


























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
create_variable_if_missing CLASSPATH "\$M2_HOME/repository/io/netty/netty-tcnative-boringssl-static/$NETTY_VERSION/netty-tcnative-boringssl-static-$NETTY_VERSION-linux-aarch_64.jar:\$M2_HOME/repository/io/netty/netty-tcnative-boringssl-static/$NETTY_VERSION/netty-tcnative-boringssl-static-$NETTY_VERSION.jar:\$M2_HOME/repository/io/netty/netty-tcnative-openssl-static/$NETTY_VERSION/netty-tcnative-openssl-static-$NETTY_VERSION-linux-aarch_64.jar:\$M2_HOME/repository/io/netty/netty-tcnative-openssl-static/$NETTY_VERSION/netty-tcnative-openssl-static-$NETTY_VERSION.jar:\$HOME/.local/share/java/java-cup-11b.jar:\$HOME/.local/share/java/java-cup-11b-runtime.jar"

