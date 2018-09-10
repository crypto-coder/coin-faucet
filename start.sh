#!/bin/sh


# Determine what Linux distribution we are using and what app installer we should use
linuxDistribution=$(lsb_release -i | sed -r 's/Distributor ID:\t//')
appInstaller=""
autoInstallSwitch=""
currentUser=$(whoami)

case "$linuxDistribution" in
    'Ubuntu') 
        appInstaller="apt-get"
        autoInstallSwitch="--assume-yes"
        ;;
    'openSUSE project') 
        appInstaller="zypper"
        autoInstallSwitch="-y"
        ;;
esac


# Install git
sudo $appInstaller install $autoInstallSwitch git

# Clone the coin-faucet repository
sudo mkdir /coinFaucet
sudo chown $currentUser:$currentUser /coinFaucet
chmod 777 /coinFaucet
git clone https://github.com/BlockSpaces/coin-faucet.git /coinFaucet

echo $linuxDistribution
echo $appInstaller
echo $currentUser