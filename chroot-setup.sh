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
./chroot-copy.sh /usr/bin/python2 /jail

# to bring in the crypto libraries
./chroot-copy.sh /usr/bin/openssl /jail

mkdir -p /jail/usr/lib /jail/usr/lib/x86_64-linux-gnu /jail/lib /jail/lib/x86_64-linux-gnu
cp -r /usr/lib/python2.7 /jail/usr/lib
cp /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 /jail/usr/lib/x86_64-linux-gnu
cp /lib/x86_64-linux-gnu/libnss_dns.so.2 /jail/lib/x86_64-linux-gnu
cp /lib/x86_64-linux-gnu/libresolv.so.2 /jail/lib/x86_64-linux-gnu
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
create_socket_dir /jail/authsvc 61016:61014 755
create_socket_dir /jail/banksvc 61017:61014 755
create_socket_dir /jail/profilesvc 61018:61014 755




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

# # Exercise 3
# # Ensure file on disk such as db can only be read by processes that should be able to read them
# set_perms 61012:61012 755 /jail/zoobar/db/person
# set_perms 61012:61012 755 /jail/zoobar/db/person/person.db
# set_perms 61012:61012 755 /jail/zoobar/db/transfer
# set_perms 61012:61012 755 /jail/zoobar/db/transfer/transfer.db

# # Exercise 4
# # db can only be accessed by the dynamic_svc
# set_perms 61014:61014 751 /jail/zoobar/db/person
# set_perms 61014:61014 751 /jail/zoobar/db/person/person.db
# set_perms 61014:61014 751 /jail/zoobar/db/transfer
# set_perms 61014:61014 751 /jail/zoobar/db/transfer/transfer.db
# set_perms 61015:61015 755 /jail/zoobar/index.cgi

# Exercise 5S



set_perms 61014:61014 770 /jail/zoobar/db/person
set_perms 61014:61014 660 /jail/zoobar/db/person/person.db
set_perms 61014:61014 770 /jail/zoobar/db/transfer
set_perms 61014:61014 660 /jail/zoobar/db/transfer/transfer.db
set_perms 61016:61014 700 /jail/zoobar/db/cred
set_perms 61016:61014 700 /jail/zoobar/db/cred/cred.db

set_perms 61010:61010 755 /jail/zoobar/echo-server.py
set_perms 61016:61014 755 /jail/zoobar/auth-server.py
set_perms 61015:61015 755 /jail/zoobar/index.cgi


# Exercise 7
set_perms 61017:61014 700 /jail/zoobar/db/bank
set_perms 61017:61014 700 /jail/zoobar/db/bank/bank.db
set_perms 61017:61014 755 /jail/zoobar/bank-server.py

# Exercise 9

set_perms 61018:61014 755 /jail/zoobar/profile-server.py
