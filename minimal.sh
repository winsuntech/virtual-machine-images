#!/bin/bash

mkdir rootfs
mount /dev/sda1 rootfs
cd rootfs

#
tar xf ../ubuntu-core-16.04-beta2-core-amd64.tar.gz

# 
echo "wisnuc"                      > etc/hostname
echo "127.0.0.1 localhost"         > etc/hosts
echo "127.0.1.1 wisnuc"            > etc/hosts
echo "[Match]"                     > /etc/systemd/network/wired.network
echo "Name=enp1s0"                >> /etc/systemd/network/wired.network
echo "[Network]"                  >> /etc/systemd/network/wired.network
echo "DHCP=ipv4"                  >> /etc/systemd/network/wired.network
echo "nameserver 208.67.222.222"   > etc/resolv.conf

mount -t devtmpfs none dev
mount -t proc none proc
mount -t sysfs none sys

chroot . apt-get update
chroot . apt-get -y install linux-image-4.4.0-16-generic net-tools iproute2 nano
chroot . bash -c 'echo "root:123456" | chpasswd'
chroot . bash -c 'echo "/dev/sda1 / ext4 defaults 1 1" > etc/fstab'
chroot . systemctl enable systemd-networkd
chroot . systemctl enable systemd-resolved

umount sys 
umount proc 
umount dev

