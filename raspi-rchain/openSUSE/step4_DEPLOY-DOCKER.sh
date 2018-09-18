


# Install Docker environment
zypper install -y docker-compose docker

# The CLASSPATH is not being passed to the rnode script correctly. Hard-code the CLASSPATH into the app_classpath variable in the Rnode start script
cd rchain
sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./target/docker/stage/opt/docker/bin/rnode

# Package the RNode docker image
sbt node/docker:publishLocal

# Setup the data storage directories for the RChain docker containers
mkdir -p $HOME/rchain/bootstrap/genesis
mkdir -p $HOME/rchain/node0

# Install the node configurations in the data storage directories
cd ../../docker/node-config
cp bootstrap/bonds.txt $HOME/rchain/bootstrap/genesis/bonds.txt
cp bootstrap/rnode.toml $HOME/rchain/bootstrap/rnode.toml
cp node0/rnode.toml $HOME/rchain/node0/rnode.toml

