#!/bin/bash

sudo fallocate -l 2G /swapfile
ls -lh /swapfilesudo
sudo chmod 600 /swapfile
ls -lh /swapfile

sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show
free -h

sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

cat /proc/sys/vm/swappiness
sudo sysctl vm.swappiness=80

cat /proc/sys/vm/vfs_cache_pressure
sudo sysctl vm.vfs_cache_pressure=80
