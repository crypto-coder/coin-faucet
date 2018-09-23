

# Disable the GUI, by setting the default to run-level 3 (multi-user)
systemctl set-default multi-user.target

# Make sure the /etc/bash.bashrc.local file exists
if [ ! -f /etc/bash.bashrc.local ]; then
    touch /etc/bash.bashrc.local
fi

# Check if wifi power_save off command is already in the bash.bashrc.local file
power_save_count=$(grep -e "power_save" -c /etc/bash.bashrc.local)

if [ $power_save_count = 0 ]; then
    echo "iw dev wlan0 set power_save off" >> /etc/bash.bashrc.local
fi