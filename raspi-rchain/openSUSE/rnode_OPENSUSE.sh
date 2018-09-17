#!/bin/sh


# Install prerequisites
#zypper addrepo https://download.opensuse.org/repositories/devel:/languages:/scala/openSUSE_Leap_42.3/devel:languages:scala.repo
#zypper refresh
#zypper install -y sbt
zypper install -y docker-compose docker
zypper install -y llvm
zypper install -y jflex
zypper install -y alex happy 
zypper addrepo https://download.opensuse.org/repositories/devel:/languages:/haskell/openSUSE_Leap_42.3/devel:languages:haskell.repo
zypper refresh
zypper install cabal-install


# Download and install Scala Build Tools
wget https://piccolo.link/sbt-1.2.1.zip
unzip sbt-1.2.1.zip
export PATH="$PATH:$(pwd)/sbt/bin"

# Download and install Haskell Tool Stack
curl -sSL https://get.haskellstack.org/ | sh  
sed -i "s/{}/{ system-ghc: true }/g" ~/.stack/config.yaml

# Download and install Glasgow Haskell Compiler
wget https://downloads.haskell.org/~ghc/8.4.1/ghc-8.4.1-aarch64-deb8-linux.tar.xz
tar xf ghc-8.4.1-aarch64-deb8-linux.tar.xz
cd ghc-8.4.1
./configure
make install
cd ..

# Download and compile BNFC
git clone https://github.com/BNFC/bnfc
cd bnfc/source
cabal install
ln -s "$(pwd)/dist/build/bnfc/bnfc" /usr/local/bin/bnfc
cd ../..

# Initialize Stack and BNFC
#stack init
#stack install
#cd -
#export PATH="$HOME/.local/bin:$HOME"
#cd ..

# Download the Kayvank-RasPi branch of RChain
git clone https://github.com/kayvank/rchain.git
cd rchain
git checkout -b raspberry-pi
git pull origin raspberry-pi

# Build and package RNode
sbt "project blockStorage" compile
sbt "project comm" compile
sbt "project shared" compile
sbt "project rspace" compile
sbt "project roscala" compile
sbt "project models" compile
sbt "project regex" compile
sbt "project crypto" compile
sbt "project rholang" compile
sbt "project casper" compile
sbt "project rholangCLI" compile
sbt "project rspaceBench" compile

# There is an issue with the different logback.xml files being configured with inconsequential differences, breaking the build.  Deduplicate them
cp ./node/src/main/resources/logback.xml ./rholang/src/main/resources/logback.xml

# Build the RNode start script
sbt "project node" assembly

# The CLASSPATH is not being passed to the rnode script correctly. Hard-code the CLASSPATH into the app_classpath variable in the Rnode start script
sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./target/universal/scripts/bin/rnode
sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./target/docker/stage/opt/docker/bin/rnode

# Package the RNode binary and docker image
sbt node/universal:packageZipTarball
sbt node/docker:publishLocal

# Unpack the RNode package and install it globally
cp node/target/universal/rnode-0.6.1.tgz ..
cd ..
tar xf rnode-0.6.1.tgz
cd rnode-0.6.1
cp "$(pwd)/bin/rnode" /usr/local/bin/rnode

# Setup the data storage directories for the RChain docker containers
mkdir -p $HOME/rchain/bootstrap/genesis
mkdir -p $HOME/rchain/node0
mkdir -p $HOME/rchain/node1
mkdir -p $HOME/rchain/repl

# Install the node configurations in the data storage directories
cp rnode/bonds.txt $HOME/rchain/bootstrap/genesis/bonds.txt

