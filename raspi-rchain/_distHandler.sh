
echo "=============================================================="
echo "-----====:::: Raspberry Pi + RChain setup script ::::====-----"
echo "=============================================================="


# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THIS_SCRIPT=`basename "$0"`
echo "Running '${THIS_SCRIPT}'"

# Determine the current Linux distribution to run the correct scripts
linuxDistribution=$(lsb_release -i | sed -r 's/Distributor ID:\t//')
distFolder=""

case "$linuxDistribution" in
    'Fedora') 
        distFolder="fedora"
        ;;
    'openSUSE project') 
        distFolder="openSUSE"
        ;;
    *)
        echo "The current Linux distribution ($linuxDistribution) has not been configured for installation.  You will need to use Fedora, openSUSE, or a Docker deployment"
        exit 1
        ;;
esac

# Execute the requested script for the appropriate Linux distribution
"${DIR}"/"${distFolder}"/"${THIS_SCRIPT}" "$@"
