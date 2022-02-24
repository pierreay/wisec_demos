#!/usr/bin/env bash

sudo apt-get update

# audio
sudo apt-get install -y linux-sound-base alsa-base alsa-utils
sudo apt-get install -y dkms build-essential linux-headers-`uname -r` alsa-base \
    alsa-firmware-loaders alsa-oss alsa-source alsa-tools alsa-tools-gui \
    alsa-utils alsamixergui
sudo usermod -a -G audio vagrant

# Install TEMPEST SDR
#git clone https://github.com/martinmarinov/TempestSDR.git

# Install gqrx
sudo apt-get install -y gqrx-sdr
