#!/bin/bash

#
# create rootfs folder
#
mkdir -p rootfs
mount /dev/sda1 rootfs
cd rootfs
rm -rf ./*

#
# untar ubuntu core rootfs
#
tar xf ../ubuntu-core-16.04-beta2-core-amd64.tar.gz

#
# set up hostname, hosts, eth0 (enp0s3 now), and fstab
#
echo "wisnuc"                        > etc/hostname
echo "127.0.0.1 localhost"           > etc/hosts
echo "127.0.1.1 wisnuc"              > etc/hosts
echo "[Match]"                       > etc/systemd/network/wired.network
echo "Name=enp0s3"                  >> etc/systemd/network/wired.network
echo "[Network]"                    >> etc/systemd/network/wired.network
echo "DHCP=ipv4"                    >> etc/systemd/network/wired.network
echo "/dev/sda1 / ext4 defaults 1 1" > etc/fstab

#
# enable universe and multiverse
#
echo "deb http://archive.ubuntu.com/ubuntu/ xenial main restricted" > etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates main restricted" >> etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ xenial universe" >> etc/apt/sources.list 
echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates universe" >> etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ xenial-backports main restricted" >> etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ xenial-security main restricted" >> etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ xenial-security universe" >> etc/apt/sources.list
echo "deb http://archive.ubuntu.com/ubuntu/ xenial-security multiverse" >> etc/apt/sources.list

#
# put a temporary DNS, important!
#
echo "nameserver 208.67.222.222"   > etc/resolv.conf

#
# mount pseudo file system
# 
mount -t devtmpfs none dev
mount -t proc none proc
mount -t sysfs none sys

#
# installation
#
chroot . apt-get update
chroot . apt-get -y install linux-image-4.4.0-16-generic 
chroot . apt-get -y install net-tools iproute2 iputils-ping sudo vim tree curl wget
chroot . apt-get -y install docker.io openssh-server

#
# set root passwd
#
chroot . bash -c 'echo "root:123456" | chpasswd'

#
# add admin 
#
chroot . adduser --uid 1000 --gecos ",,," --disabled-password --home /home/admin --shell /bin/bash admin
chroot . bash -c 'echo "admin:123456" | chpasswd'
# chroot . adduser admin
chroot . addgroup admin adm
chroot . addgroup admin sudo

chroot . systemctl enable systemd-networkd
chroot . systemctl enable systemd-resolved

# according to Arch doc
chroot . rm -rf /etc/resolv.conf
chroot . ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf

umount sys 
umount proc 
umount dev
cd ..
umount rootfs


