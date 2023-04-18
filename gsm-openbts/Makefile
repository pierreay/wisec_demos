red:="\033[31m"
green:="\033[32m"
blue:="\033[34m"
reset:="\033[0m"
define myinfo
	@echo $(blue)[INFO]$(reset) $(1)
endef

help:
	$(info make help)
	$(info make host-install)
	$(info make host-android-enable-wifi)
	$(info make host-android-share-screen)
	$(info make guest-install)
	$(info make guest-install-reset)
	$(info make guest-launch-sipauth)
	$(info make guest-launch-smqueue)
	$(info make guest-launch-asterisk)
	$(info make guest-launch-openbts)
	$(info make guest-launch-openbtscli)

# Targets for the host OS
# =======================

host-install:
	sudo apt-get install virtualbox virtualbox-dkms virtualbox-ext-pack virtualbox-guest-additions-iso virtualbox-qt
	sudo apt-get install vagrant
	sudo usermod -aG vboxusers $$USER
	$(call myinfo, Reboot the system and make sure $$USER is in the vboxusers group.)

ANDROID_IP=192.168.1.7

host-android-enable-wifi:
	$(call myinfo, Enable ADB over TCP/IP from USB debugging:)
	scrcpy --tcpip

host-android-share-screen:
	scrcpy --tcpip=$(ANDROID_IP)

# Targets for the guest VM
# ========================

INSTALL_DIR="$${HOME}/openbts-install"

guest-install: .sentinel/install-apt .sentinel/install-openbts .sentinel/build-openbts-radio .sentinel/build-openbts-db
	mkdir -p $(@D)
	$(call myinfo, Download USRP firmwares:)
	sudo /usr/lib/uhd/utils/uhd_images_downloader.py
	touch $@

.sentinel/install-apt:
	mkdir -p $(@D)
	$(call myinfo, Prepare the system with required APT packages:)
	sudo apt-get update
	sudo apt-get install -y python-software-properties software-properties-common git stow autoconf libtool libosip2-dev libortp-dev libusb-1.0-0-dev g++ sqlite3 libsqlite3-dev erlang libreadline6-dev libncurses5-dev
	touch $@

.sentinel/install-openbts:
	mkdir -p $(@D)
	mkdir -p $(INSTALL_DIR)
	$(call myinfo, Clone the main OpenBTS repository:)
	cd $(INSTALL_DIR) && git clone https://github.com/RangeNetworks/dev.git
	$(call myinfo, Clone all dependencies repositories:)
	cd $(INSTALL_DIR)/dev && ./clone.sh
	$(call myinfo, Install the A5/3 Call Encryption Library with Stow:)
	mkdir -p $(INSTALL_DIR)/dev/liba53/build/usr/lib
	mkdir -p $(INSTALL_DIR)/dev/liba53/build/usr/include
	cd $(INSTALL_DIR)/dev/liba53 && sudo make install DESTDIR=$(INSTALL_DIR)/dev/liba53/build
	cd $(INSTALL_DIR)/dev/liba53 && sudo stow -t / build
	touch $@

.sentinel/build-openbts-radio: .sentinel/install-openbts
	mkdir -p $(@D)
	$(call myinfo, Build OpenBTS for Ettus B200/B200mini/B210 radio:)
	cd $(INSTALL_DIR)/dev && ./build.sh B210
	touch $@

.sentinel/build-openbts-db: .sentinel/build-openbts-radio
	mkdir -p $(@D)
	$(call myinfo, Initialize OpenBTS database:)
	sudo mkdir -p /etc/OpenBTS
	cd $(INSTALL_DIR)/dev/openbts && sudo sqlite3 -init ./apps/OpenBTS.example.sql /etc/OpenBTS/OpenBTS.db ".quit"
	$(call myinfo, Initialize Asterisk and SQQueue logs directory:)
	sudo mkdir -p /var/lib/asterisk/sqlite3dir
	sudo mkdir -p /var/lib/OpenBTS
	touch $@

guest-install-reset:
	rm -rf .sentinel

guest-launch-sipauth:
	$(call myinfo, Start SIP Authorization Server \(SIPAuthServe\, which processes SIP REGISTER requests\):)
	cd $(INSTALL_DIR)/dev/subscriberRegistry/apps && sudo ./sipauthserve

guest-launch-smqueue:
	$(call myinfo, Start SIP MESSAGE Queue \(SMQueue\, which processes SIP MESSAGE requests\):)
	cd $(INSTALL_DIR)/dev/smqueue/smqueue && sudo ./smqueue

guest-launch-asterisk:
	$(call myinfo, Start Asterisk \(VoIP switch responsible for handling SIP INVITE requests\):)
	cd $(INSTALL_DIR)/dev/asterisk/asterisk-11.7.0/main && sudo LD_LIBRARY_PATH=./ ./asterisk -vv

guest-launch-openbts:
	$(call myinfo, Start OpenBTS \(implements the GSM air interface in software\):)
	cd $(INSTALL_DIR)/dev/openbts/debian/openbts/OpenBTS && sudo ./OpenBTS

guest-launch-openbtscli:
	$(call myinfo, Start OpenBTS command-line interface:)
	cd $(INSTALL_DIR)/dev/openbts/debian/openbts/OpenBTS && sudo ./OpenBTSCLI
