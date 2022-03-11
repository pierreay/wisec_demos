#!/bin/bash

sudo docker run -it \
     -v "$(realpath ../../)":/docker \
     --net=host \
     --env=DISPLAY -v ~/.Xauthority:/home/screaming/.Xauthority:rw \
     --privileged -v /dev/bus/usb:/dev/bus/usb \
     -v /dev/shm:/dev/shm \
     -v /etc/machine-id:/etc/machine-id \
     -v /run/user/$(id -g)/pulse:/run/user/$(id -g)/pulse \
     -v /var/lib/dbus:/var/lib/dbus \
     -v ~/.pulse:/home/screaming/.pulse \
     --group-add=dialout \
     sc /bin/bash
