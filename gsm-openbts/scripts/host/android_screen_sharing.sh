#!/bin/bash

wifi() {
    adb tcpip 5555
    sleep 2
    adb connect $1:5555
    exit
}

share_screen() {
    adb shell screenrecord --output-format=h264 - | ffplay -
    exit
}

help() {
    echo "$0 wifi IPADDR -- Restart ADB into Wi-Fi mode and connect to the phone at IPADDR."
    echo "$0 share_screen -- Start Android screen sharing (need to be unlocked) through ADB over Wi-Fi and FFmpeg decoding."
}

# Wrapper to call individual function.
$@
help
