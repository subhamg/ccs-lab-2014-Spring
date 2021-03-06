#!/bin/sh -x
if id | grep -qv uid=0; then
    echo "Must run setup as root"
    exit 1
fi

create_socket_dir() {
    local dirname="$1"
    local ownergroup="$2"
    local perms="$3"

    mkdir -p $dirname
    chown $ownergroup $dirname
    chmod $perms $dirname
}

set_perms() {
    local ownergroup="$1"
    local perms="$2"
    local pn="$3"

    chown $ownergroup $pn
    chmod $perms $pn
}

rm -rf /jail
mkdir -p /jail
cp -p index.html /jail

./chroot-copy.sh zookd /jail
./chroot-copy.sh zookfs /jail

#./chroot-copy.sh /bin/bash /jail

./chroot-copy.sh /usr/bin/env /jail
./chroot-copy.sh /usr/bin/python /jail

# to bring in the crypto libraries
./chroot-copy.sh /usr/bin/openssl /jail

mkdir -p /jail/usr/lib /jail/usr/lib/i386-linux-gnu /jail/lib /jail/lib/i386-linux-gnu
cp -r /usr/lib/python2.7 /jail/usr/lib
cp -r /usr/lib/pymodules /jail/usr/lib
cp /usr/lib/i386-linux-gnu/libsqlite3.so.0 /jail/usr/lib/i386-linux-gnu
cp /usr/lib/libxslt.so.1 /jail/usr/lib
cp /usr/lib/libexslt.so.0 /jail/usr/lib
cp /usr/lib/libxml2.so.2 /jail/usr/lib
cp /lib/libgcrypt.so.11 /jail/lib
cp /lib/libgpg-error.so.0 /jail/lib
cp /lib/i386-linux-gnu/libnss_dns.so.2 /jail/lib/i386-linux-gnu
cp /lib/i386-linux-gnu/libresolv.so.2 /jail/lib/i386-linux-gnu
cp -r /lib/resolvconf /jail/lib

mkdir -p /jail/usr/local/lib
cp -r /usr/local/lib/python2.7 /jail/usr/local/lib

mkdir -p /jail/etc
cp /etc/localtime /jail/etc/
cp /etc/timezone /jail/etc/
cp /etc/resolv.conf /jail/etc/

mkdir -p /jail/usr/share/zoneinfo
cp -r /usr/share/zoneinfo/America /jail/usr/share/zoneinfo/

create_socket_dir /jail/echosvc 61010:61010 755
create_socket_dir /jail/authavc 61015:61015 755
create_socket_dir /jail/banksvc 61016:61016 755
create_socket_dir /jail/honeycheckersvc 61017:61017 755
create_socket_dir /jail/profilesvc 61018:61018 755
create_socket_dir /jail/profilechargesvc 61019:61019 755

mkdir -p /jail/tmp
chmod a+rwxt /jail/tmp

mkdir -p /jail/dev
mknod /jail/dev/urandom c 1 9

cp -r zoobar /jail/
rm -rf /jail/zoobar/db

python /jail/zoobar/zoodb.py init-person
python /jail/zoobar/zoodb.py init-transfer
python /jail/zoobar/zoodb.py init-cred
python /jail/zoobar/zoodb.py init-bank
python /jail/zoobar/zoodb.py init-honeychecker
python /jail/zoobar/zoodb.py init-profile

chown 61012:61012 /jail/zoobar/db/person/
chmod 330 /jail/zoobar/db/person
chown 61017:61017 /jail/zoobar/db/honeychecker/
chmod 300 /jail/zoobar/db/honeychecker
chown 61015:61015 /jail/zoobar/db/cred/
chmod 300 /jail/zoobar/db/cred/
chown 61012:61012 /jail/zoobar/db/transfer/
chmod 330 /jail/zoobar/db/transfer
chown 61016:61016 /jail/zoobar/db/bank/
chmod 300 /jail/zoobar/db/bank
chown 61019:61019 /jail/zoobar/db/profile
chmod 331 /jail/zoobar/db/profile

chown 61012:61012 /jail/zoobar/db/person/person.db
chmod 660 /jail/zoobar/db/person/person.db
chown 61017:61017 /jail/zoobar/db/honeychecker/honeychecker.db
chmod 600 /jail/zoobar/db/honeychecker/honeychecker.db
chown 61015:61015 /jail/zoobar/db/cred/cred.db
chmod 600 /jail/zoobar/db/cred/cred.db
chown 61012:61012 /jail/zoobar/db/transfer/transfer.db
chmod 660 /jail/zoobar/db/transfer/transfer.db
chown 61016:61016 /jail/zoobar/db/bank/bank.db
chmod 600 /jail/zoobar/db/bank/bank.db
chown 61019:61019 /jail/zoobar/db/profile/profile.db
chmod 644 /jail/zoobar/db/profile/profile.db

chown 61014:61014 /jail/zoobar/index.cgi
