


# Install Docker environment
zypper install -y docker-compose docker
systemctl enable docker
systemctl start docker

# Package the RNode docker image
cd rchain
sbt node/docker:publishLocal

# The RNode application does not contain the CLASSPATH, so we need to destroy the old docker image and generate it manually
export OLD_IMAGE_ID=$(docker images --filter=reference='kayvank/kayvank/rnode' --format "{{.ID}}")
docker rmi $OLD_IMAGE_ID

cd ./node/target/docker/stage
sed -i 's@ app_classpath=\"@ app_classpath=\"'"$CLASSPATH"':@g' ./opt/docker/bin/rnode
docker build -t blockspaces/rnode:latest .

# Setup the data storage directories for the RChain docker containers
mkdir -p $HOME/rchain/docker/bootstrap/genesis
mkdir -p $HOME/rchain/docker/node0
mkdir -p $HOME/rchain/native/bootstrap/genesis
mkdir -p $HOME/rchain/native/node0
chown -R u+w $HOME/rchain
chown -R g+w $HOME/rchain

# Install the node configurations in the data storage directories
cd ../docker/node-config
cp bootstrap/bonds.txt $HOME/rchain/docker/bootstrap/genesis/bonds.txt
cp bootstrap/rnode.toml $HOME/rchain/docker/bootstrap/rnode.toml
cp node0/rnode.toml $HOME/rchain/docker/node0/rnode.toml
cp bootstrap/bonds.txt $HOME/rchain/native/bootstrap/genesis/bonds.txt
cp bootstrap/rnode.toml $HOME/rchain/native/bootstrap/rnode.toml
cp node0/rnode.toml $HOME/rchain/native/node0/rnode.toml

# Copy the docker-compose file over to the rchain/docker folder
cd ..
cp docker-compose.yml $HOME/rchain/docker/docker-compose.yml

# Re-enable the desktop
systemctl set-default graphical.target
