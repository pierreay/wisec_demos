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
	$(info make guest-install)
	$(info make guest-install-reset)

# Installation for the host OS
# =============================

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

# Installation for the guest VM
# =============================

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
