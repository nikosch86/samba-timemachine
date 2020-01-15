#!/bin/sh

TM_USERNAME="${TM_USERNAME:-timemachine}"
TM_UID="${TM_UID:-1000}"
TM_GID="${TM_GID:-${TM_UID}}"
TM_PASSWORD="${TM_PASSWORD:-timemachine}"
TM_GROUPNAME="${TM_GROUPNAME:-timemachine}"
TM_SHARENAME="${TM_SHARENAME:-TimeMachine}"
TM_SIZE_LIMIT="${TM_SIZE_LIMIT:-0}"

WORKGROUP="${WORKGROUP:-WORKGROUP}"
SHARENAME="${SHARENAME:-Share}"
MIMIC_MODEL="${MIMIC_MODEL:-TimeCapsule8,119}"

echo "creating avahi smbd config to mimic model ${MIMIC_MODEL}"
echo "<?xml version=\"1.0\" standalone='no'?><!--*-nxml-*-->
<!DOCTYPE service-group SYSTEM \"avahi-service.dtd\">
<service-group>
  <name replace-wildcards=\"yes\">%h</name>
  <service>
    <type>_smb._tcp</type>
    <port>445</port>
  </service>
  <service>
    <type>_device-info._tcp</type>
    <port>0</port>
  <txt-record>model=${MIMIC_MODEL}</txt-record>
  </service>
  <service>
   <type>_adisk._tcp</type>
   <txt-record>sys=waMa=0,adVF=0x100</txt-record>
   <txt-record>dk0=adVN=TimeMachine,adVF=0x82</txt-record>
 </service>
</service-group>" > /etc/avahi/services/smbd.service

echo "creating smb config for ${WORKGROUP} and share ${TM_SHARENAME}"
echo "[global]
 server role = standalone server
 workgroup = ${WORKGROUP}
 security = user

 min receivefile size = 16384
 use sendfile = Yes
 aio read size = 16384
 aio write size = 16384
 socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072

 passdb backend = tdbsam
 obey pam restrictions = yes
 unix password sync = yes
 map to guest = bad user
 dns proxy = no
 client min protocol = SMB2
 smb encrypt = mandatory

 wide links = yes
 unix extensions = no
 follow symlinks = yes
 durable handles = yes
 kernel oplocks = no
 kernel share modes = no
 posix locking = no
 acl allow execute always = yes

 log file = /var/log/samba/log.%m
 logging = file
 max log size = 1000
 load printers = no
 fruit:advertise_fullsync = true
[${TM_SHARENAME}]
 fruit:aapl = yes
 fruit:time machine = yes
 fruit:time machine max size = ${TM_SIZE_LIMIT}
 path = /data/${TM_SHARENAME}
 valid users = ${TM_USERNAME}
 browseable = yes
 writable = yes
 ea support = yes
 vfs objects = catia fruit streams_xattr
 [${SHARENAME}]
  path = /data/${SHARENAME}
  valid users = ${TM_USERNAME}
  browseable = yes
  writable = yes
  ea support = yes
  vfs objects = catia fruit streams_xattr" > /etc/samba/smb.conf

 # check to see if group exists; if not, create it
 if grep -q -E "^${TM_GROUPNAME}:" /etc/group > /dev/null 2>&1
 then
   echo "INFO: Group exists; skipping creation"
 else
   echo "INFO: Group doesn't exist; creating..."
   # create the group
   addgroup -g "${TM_GID}" "${TM_GROUPNAME}"
 fi

 # check to see if user exists; if not, create it
 if id -u "${TM_USERNAME}" > /dev/null 2>&1
 then
   echo "INFO: User exists; skipping creation"
 else
   echo "INFO: User doesn't exist; creating..."
   # create the user
   adduser -D -H -u "${TM_UID}" -G "${TM_GROUPNAME}" -s /bin/false -D "${TM_USERNAME}"
   echo -e "${TM_PASSWORD}\n${TM_PASSWORD}" | smbpasswd -s -a "${TM_USERNAME}"
 fi

mkdir -p "/data/${TM_SHARENAME}" "/data/${SHARENAME}"
chown -R "${TM_USERNAME}":"${TM_GROUPNAME}" "/data/${TM_SHARENAME}" "/data/${SHARENAME}"

rm -f /run/samba/nmbd.pid /run/samba/smbd.pid /run/dbus.pid /run/avahi-daemon/pid

exec "${@}"
