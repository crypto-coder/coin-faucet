
# Download the RasPi branch of RChain
if [ -d "$(pwd)/rchain" ]; then
    rm -rf "$(pwd)/rchain"
fi
git clone https://github.com/BlockSpaces/rchain.git
cd rchain
git checkout -b raspberry-pi
git pull origin raspberry-pi

# Build and package RNode
sbt rholang/bnfc:generate
sbt "project node" compile
#sbt "project rholangCLI" compile
#sbt "project rspaceBench" compile

# Build the RNode start script
sbt "project node" assembly

# The CLASSPATH is not being passed to the rnode script correctly. Hard-code the CLASSPATH into the app_classpath variable in the Rnode start script
sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./node/target/universal/scripts/bin/rnode

# Package the RNode binary
sbt node/universal:packageZipTarball

# Unpack the RNode package and install it globally
cp node/target/universal/rnode-0.6.1.tgz ..
cd ..
tar xf rnode-0.6.1.tgz
cd rnode-0.6.1
cp "$(pwd)/bin/rnode" /usr/local/bin/rnode
