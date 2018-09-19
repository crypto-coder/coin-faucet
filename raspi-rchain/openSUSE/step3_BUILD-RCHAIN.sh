
# Install RChain build components
zypper install -y llvm jflex alex happy
zypper addrepo https://download.opensuse.org/repositories/devel:/languages:/haskell/openSUSE_Leap_42.3/devel:languages:haskell.repo | echo 'a'
zypper refresh
zypper install -y cabal-install


# Download and install Scala Build Tools
if [ ! -d "$(pwd)/sbt" ]; then
    wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 50 --continue https://piccolo.link/sbt-1.2.1.zip
    unzip sbt-1.2.1.zip
fi
export PATH="$PATH:$(pwd)/sbt/bin"

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

# Download the RasPi branch of RChain
if [ -d "$(pwd)/rchain" ]; then
    rm -rf "$(pwd)/rchain"
fi
git clone https://github.com/BlockSpaces/rchain.git
cd rchain
git checkout -b raspberry-pi
git pull origin raspberry-pi

# Build and package RNode
#sbt "project comm" compile
#sbt "project rholang" compile
#sbt "project casper" compile
#sbt "project crypto" compile
#sbt "project shared" compile
#sbt "project models" compile
#sbt "project blockStorage" compile
#sbt "project rspace" compile


sbt "project roscala" compile
sbt "project regex" compile
sbt rholang/bnfc:generate
sbt "project node" compile
sbt "project rholangCLI" compile
#sbt "project rspaceBench" compile

# There is an issue with the different logback.xml files being configured with inconsequential differences, breaking the build.  Deduplicate them
#cp ./node/src/main/resources/logback.xml ./rholang/src/main/resources/logback.xml

# Build the RNode start script
#sbt "project node" assembly

# The CLASSPATH is not being passed to the rnode script correctly. Hard-code the CLASSPATH into the app_classpath variable in the Rnode start script
#sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./target/universal/scripts/bin/rnode

# Package the RNode binary
#sbt node/universal:packageZipTarball

# Unpack the RNode package and install it globally
#cp node/target/universal/rnode-0.6.1.tgz ..
#cd ..
#tar xf rnode-0.6.1.tgz
#cd rnode-0.6.1
#cp "$(pwd)/bin/rnode" /usr/local/bin/rnode
