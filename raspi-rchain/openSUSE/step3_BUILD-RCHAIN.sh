
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

# Build and package the RNode start script
sbt "project node" assembly
sbt node/universal:packageZipTarball

# re-Package the RNode binary
sbt node/universal:packageZipTarball

# Unpack the RNode package and install it globally
cp node/target/universal/rnode-0.6.1.tgz ..
cd ..
if [ -d "$(pwd)/rnode-0.6.1" ]; then
    rm -rf rnode-0.6.1
fi
tar xf rnode-0.6.1.tgz

# The CLASSPATH is not being passed to the rnode script correctly. Hard-code the CLASSPATH into the app_classpath variable in the Rnode start script
sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./rnode-0.6.1/bin/rnode

# Make sure the /etc/bash.bashrc.local file exists
if [ ! -f /etc/bash.bashrc.local ]; then
    touch /etc/bash.bashrc.local
fi

# Check if rnode is already in /etc/bash.bashrc.local 
rnode_bash_count=$(grep -e "rnode-0.6.1" -c /etc/bash.bashrc.local)
if [ $rnode_bash_count = 0 ]; then
    echo "export PATH=$PATH:$(pwd)/rnode-0.6.1/bin" >> /etc/bash.bashrc.local
fi

# Check if rnode is already in PATH
rnode_path_count=$(echo $PATH | grep -e "rnode-0.6.1" -c)
if [ $rnode_path_count = 0 ]; then
    export PATH=$PATH:$(pwd)/rnode-0.6.1/bin
fi
