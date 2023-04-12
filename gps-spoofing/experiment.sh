#!/bin/bash

####################
# This is our own brewed script for setting up a wifi network
# it run on the remote machine - either sender or receiver
# and is in charge of initializing a small ad-hoc network
#
# Thanks to the RunString class, we can just define this as
# a python string, and pass it arguments from python variables
#

function hotspot-create (){
    source /etc/profile.d/nodes.sh
    turn-off-wireless
    modprobe ath9k
    ifname=$(wait-for-interface-on-driver ath9k)
    nmcli con add type wifi ifname $ifname con-name Hotspot autoconnect yes ssid Hotspot
    nmcli con modify Hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
    nmcli con modify Hotspot wifi-sec.key-mgmt wpa-psk
    nmcli con modify Hotspot wifi-sec.psk "password"
    nmcli con up Hotspot
}

function usrp-b210-set (){
    /usr/lib/uhd/utils/uhd_images_downloader.py
    uhd_find_devices
}

function usrp-2-set (){
    ifconfig data down 2> /dev/null;
    ip link set data name usrp;
    ifconfig usrp 192.168.10.1 netmask 255.255.255.0 broadcast 192.168.10.255;
    ifconfig usrp up
}

function spoofer-install (){
    git clone  https://github.com/osqzss/gps-sdr-sim
    cd gps-sdr-sim
    make
}

function spoof (){
    cd /root/gps-sdr-sim
    ./gps-sdr-sim -v -e brdc3540.14n -b 16 -s 2500000 -l 1.362334,103.992769,1
    ./gps-sdr-sim-uhd.py -t gpssim.bin -s 2500000 -x 0 -f 1575420000
}

########################################
# just a wrapper so we can call the individual functions. so e.g.
# B3-wireless.sh tracable-ping 10.0.0.2 20
# results in calling tracable-ping 10.0.0.2 20

"$@"
