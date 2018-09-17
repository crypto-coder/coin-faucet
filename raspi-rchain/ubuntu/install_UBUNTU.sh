#!/bin/sh

# Clean out last installation attempt
rm -rf libsodium-1.0.16
rm libsodium-1.0.16.tar.gz
rm -rf netty-tcnative
rm libressl-2.8.0.tar.gz
rm -rf libressl-2.8.0
rm -rf boringssl


# Install dependencies
sudo apt-get install --assume-yes automake cmake
sudo apt-get install --assume-yes libapr1 libaprutil1 libaprutil1-dev
sudo apt-get install --assume-yes liblmdb-dev
sudo apt-get install --assume-yes libtool
sudo apt-get install --assume-yes openssl libssl-dev
sudo apt-get install --assume-yes golang-go

# Get Oracle JDK8 
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer

# Configure Java
# echo JAVA_HOME="/usr/lib/jvm/java-8-oracle" >> /etc/environment
source /etc/environment
echo $JAVA_HOME

# Get Ninja
git clone https://github.com/ninja-build/ninja.git
cd ninja

# Build and install Ninja
./configure --bootstrap
sudo cp ninja /usr/local/bin
cd ..

# Get libsodium
wget https://download.libsodium.org/libsodium/releases/libsodium-1.0.16.tar.gz
tar xvf libsodium-1.0.16.tar.gz

# Build and install libsodium
cd libsodium-1.0.16
./configure
make && make check
sudo make install
cd ..

# Get LibreSSL
wget http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-2.8.0.tar.gz
tar xvf libressl-2.8.0.tar.gz

# Build and install LibreSSL
cd libressl-2.8.0
./configure
make && make install
cd ..

# Get BoringSSL
git clone https://boringssl.googlesource.com/boringssl

# Build and install BoringSSL
cd boringssl
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=1 ..
make
cd ssl
sudo cp libssl.* /usr/local/lib
cd ../crypto
sudo cp libcrypto.* /usr/local/lib
cd ../decrepit
sudo cp libdecrepit.* /usr/local/lib
cd ../../..

# Get netty-tcnative (Tomcat Native)
git clone https://github.com/netty/netty-tcnative.git

# Build and install netty-tcnative (Tomcat Native)
cd netty-tcnative
./mvnw compile
sudo ./mvnw install


