#!/bin/bash

# sleep until instance is ready
# until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
#   sleep 1
# done

# install htop
# apt-get update
# apt-get -y install htop

# yum list available
sudo yum update - y
sudo yum install -y htop
