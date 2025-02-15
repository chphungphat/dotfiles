#!/bin/bash

echo "Choose the option:"
echo "1. Disable iwlwifi (May fix headset 2.4ghz issue)"
echo "2. Remove iwlwifi disable config"
read -p "Option: " option

case $option in
  1)
    echo "Disabling iwlwifi..."
    sudo tee /etc/modprobe.d/iwlwifi-opt.conf <<<"options iwlwifi bt_coex_active=N"
    echo "Done"
    ;;
  2)
    echo "Removing iwlwifi disable config..."
    sudo rm /etc/modprobe.d/iwlwifi-opt.conf
    echo "Done"
    ;;
  *)
    echo "Invalid option"
    exit 1
    ;;
esac
