# WiSec

Welcome to the git repo for the WiSec class at EURECOM.

# Index

* [Rogue GSM base station](#RogueGSM)

## <a name="RogueGSM"></a>Rogue GSM base station

***Warning***
This is a purely technical guide.
Refer to the regulations in your country to check what you are allowed and not allowed to do.

We will use OpenBTS and a USRP B210 software defined radio to build a rogue GSM base station.
[Getting Started with OpenBTS Range Networks](http://www.openbts.org/site/wp-content/uploads/ebook/Getting_Started_with_OpenBTS_Range_Networks.pdf)
is a good reference.

We use Vagrant and VirtualBox to setup a virtual machine. This makes it easy to setup the environment and it is independent from the operating system you have. Please make sure you have installed Vagrant and VirtualBox before continuing. Refer to the official documentation and tutorials.

You will also need some test phones for the experiments.
Beware that you will collect the IMEI and IMSI of these phones.
The idea for the demo is to catch the IMEI and IMSI of the testphones, and whitesit them, so that
no other user will accidentally connect to the test network.

Connect the USRP B210 to you machine, then prepare the virtual machine, the first time this will take several minutes.
```
$ cd openbts
$ vagrant up
```

You can not connect to the virtual machine.
```
$ vagrant ssh
```

First, check the radio.
```
> uhd_find_devices
linux; GNU C++ version 5.3.1 20151219; Boost_105800; UHD_003.009.002-0-unknown

--------------------------------------------------
-- UHD Device 0
--------------------------------------------------
Device Address:
    type: b200
    name: MyB210
    serial: 3189F57
    product: B210
```
```
> cd /home/vagrant/dev/openbts/debian/openbts/OpenBTS/
> ./transceiver
linux; GNU C++ version 5.3.1 20151219; Boost_105800; UHD_003.009.002-0-unknown

Using internal frequency reference
-- Detected Device: B210
-- Loading FPGA image: /usr/share/uhd/images/usrp_b210_fpga.bin... done
-- Operating over USB 3.
-- Detecting internal GPSDO.... No GPSDO found
-- Initialize CODEC control...
-- Initialize Radio control...
-- Performing register loopback test... pass
-- Performing register loopback test... pass
-- Performing CODEC loopback test... pass
-- Performing CODEC loopback test... pass
-- Asking for clock rate 16.000000 MHz... 
-- Actually got clock rate 16.000000 MHz.
-- Performing timer loopback test... pass
-- Performing timer loopback test... pass
-- Setting master clock rate selection to 'automatic'.
-- Asking for clock rate 32.000000 MHz... 
-- Actually got clock rate 32.000000 MHz.
-- Performing timer loopback test... pass
-- Performing timer loopback test... pass
-- Asking for clock rate 26.000000 MHz... 
-- Actually got clock rate 26.000000 MHz.
-- Performing timer loopback test... pass
-- Performing timer loopback test... pass
```
Kill with Ctrl-C.
```
^CReceived shutdown signal
Shutting down transceiver...
```

From now on it will be handy to have multiple terminals.
A good way to accomplish that via ssh is to use the ```tmux``` program.
Quick tutorial:
1. ```tmux``` to start a new session.
2. ```Ctrl-b c``` to create a new terminal.
3. ```Ctrl-b n``` to move to next terminal.
4. ```Ctrl-b p``` to move to previous terminal.
4. ```Ctrl-b d``` to detach from the session.
5. ```tmux a``` to reattach.

Now, start each of the following programs in a separate terminal.
```
> cd ~/dev/subscriberRegistry/apps
> sudo ./sipauthserve
```
```
> cd ~/dev/smqueue/smqueue/
> sudo ./smqueue
```
```
> cd ~/dev/asterisk/asterisk-11.7.0/main
> sudo LD_LIBRARY_PATH=./ ./asterisk -vv
```
```
> cd ~/dev/openbts/debian/openbts/OpenBTS/
> sudo ./OpenBTS
```
```
> cd ~/dev/openbts/debian/openbts/OpenBTS/
> sudo ./OpenBTSCLI
```

Now, you can type commands in the OpenBTSCLI command line interface (OpenBTS>).

Adjust the receive gain.
2dB is a good value when the phone are close, to avoid clipping.
Incerease to 10dB if you the phone is more distant.
```
OpenBTS> rxgain 2
```

Set the transmission attenuation, e.g. 20dB.
Adjust to your needs.
```
OpenBTS> power 20
```

Once you are done, halt your virtual machine.
```
$ vagrant halt
```




