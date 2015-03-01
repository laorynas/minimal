#!/bin/sh

cd work

rm -rf rootfs

cd busybox
cd $(ls -d *)

# Install busybox as a rootfs
cp -R _install ../../rootfs

# Install static python
cd ../../python
cp python* ../rootfs/usr/bin/python
chmod +x ../rootfs/usr/bin/python

# prepare rootfs
cd ../rootfs

rm -f linuxrc

mkdir dev
mkdir etc
mkdir proc
mkdir root
mkdir src
mkdir sys
mkdir tmp
chmod 1777 tmp

cd etc

cat > rc << EOF
#!/bin/sh

dmesg -n 1
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys

ip link set lo up
ip link set eth0 up
udhcpc -b -i eth0 -s /etc/rc.dhcp

EOF

chmod +x rc

cat > rc.dhcp << EOF
#!/bin/sh

ip addr add \$ip/\$mask dev \$interface
if [ -n "\$router" ]; then
    ip route add default via \$router
fi
EOF

chmod +x rc.dhcp

cat > inittab << EOF
::sysinit:/etc/rc
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::respawn:/bin/cttyhack /bin/sh
tty2::respawn:/bin/sh
tty3::respawn:/bin/sh
tty4::respawn:/bin/sh

EOF

cd ..

cat > init << EOF
#!/bin/sh

exec /sbin/init

EOF

chmod +x init

cp ../../*.sh src
cp ../../.config src
chmod +r src/*.sh
chmod +r src/.config

cd ../..

