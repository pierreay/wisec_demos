#!/usr/bin/env bash

# Install OpenBTS
# http://openbts.org/site/wp-content/uploads/ebook/Getting_Started_with_OpenBTS_Range_Networks.pdf
# http://openbts.org/w/index.php?title=BuildInstallRun#Ubuntu_12.04_i386

sudo apt-get install -y software-properties-common python-software-properties
sudo add-apt-repository ppa:git-core/ppa
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y autoconf libtool libosip2-dev libortp-dev libusb-1.0-0-dev g++ sqlite3 libsqlite3-dev erlang libreadline6-dev libncurses5-dev

cd /home/vagrant/
git clone https://github.com/RangeNetworks/dev.git
cd dev
./clone.sh
#./switchto.sh 4.0
cd liba53
sudo make install
cd ..

# https://sourceforge.net/p/openbts/mailman/message/35656911/
#sed -i 's/libortp9/libortp8/g' build.sh
sed -i 's?http://google-coredumper.googlecode.com/files/coredumper-$VERSION.tar.gz?https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/google-coredumper/coredumper-$VERSION.tar.gz?g' libcoredumper/build.sh
sed -i 's/4/5/g 'libcoredumper/coredumper-1.2.1/debian/compat
echo "5" > liba53/debian/compat

./build.sh B210

cd /home/vagrant/dev/openbts
sudo mkdir /etc/OpenBTS
sudo sqlite3 -init ./apps/OpenBTS.example.sql /etc/OpenBTS/OpenBTS.db ".quit"

cd /home/vagrant
/usr/lib/uhd/utils/uhd_images_downloader.py

# TODO (why??)
mkdir -p /var/lib/asterisk/sqlite3dir
# smqueue try to write logs in this directory, it has to be manually created.
sudo mkdir -p /var/lib/OpenBTS
