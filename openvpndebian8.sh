#!/bin/bash
#script by Scriptking SCK debian8

if [[ $EUID -ne 0 ]]; then
   echo "เข้าสู่ระบบ root ก่อน sudo -i" 
   exit 1
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Bangkok /etc/localtime

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# update repository
Y | apt-get update

# Install OpenVPN dan Easy-RSA
Y | apt-get install openvpn easy-rsa

# copykan script generate Easy-RSA ke direktori OpenVPN
cp -r /usr/share/easy-rsa/ /etc/openvpn

# Buat direktori baru untuk easy-rsa keys
mkdir /etc/openvpn/easy-rsa/keys

# Kemudian edit file variabel easy-rsa
# nano /etc/openvpn/easy-rsa/vars
wget -O /etc/openvpn/easy-rsa/vars "https://ocs-deb8.000webhostapp.com/vpn/vars.conf"
# edit projek export KEY_NAME="white-vps"
# Save dan keluar dari editor

# generate Diffie hellman parameters
openssl dhparam -out /etc/openvpn/dh2048.pem 2048

# inialisasikan Public Key
cd /etc/openvpn/easy-rsa
. ./vars
./clean-all
# Certificate Authority (CA)
./build-ca

# buat server key name yang telah kita buat sebelum nya yakni "white-vps"
./build-key-server white-vps

# generate ta.key
openvpn --genkey --secret keys/ta.key

# Buat config server UDP
cd /etc/openvpn

cat > /etc/openvpn/server.conf <<-END
port 1194
proto udp
dev tun
ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/white-vps.crt
key easy-rsa/keys/white-vps.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status server-udp.log
verb 3
END

# Buat config server TCP
cd /etc/openvpn

cat > /etc/openvpn/server-tcp.conf <<-END
port 1194
proto tcp
dev tun
ca easy-rsa/keys/ca.crt
cert easy-rsa/keys/white-vps.crt
key easy-rsa/keys/white-vps.key
dh dh2048.pem
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
client-cert-not-required
username-as-common-name
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 5 30
comp-lzo
persist-key
persist-tun
status server-tcp.log
verb 3
END

cp /etc/openvpn/easy-rsa/keys/{white-vps.crt,white-vps.key,ca.crt,ta.key} /etc/openvpn
ls /etc/openvpn

# nano /etc/default/openvpn
sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/g' /etc/default/openvpn
# Cari pada baris #AUTOSTART=”all” hilangkan tanda pagar # didepannya sehingga menjadi AUTOSTART=”all”. Save dan keluar dari editor

# restart openvpn dan cek status openvpn
/etc/init.d/openvpn restart
/etc/init.d/openvpn status

# aktifkan ip4 forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
# edit file sysctl.conf
# nano /etc/sysctl.conf
# Uncomment hilangkan tanda pagar pada #net.ipv4.ip_forward=1

# firewall untuk memperbolehkan akses UDP dan akses jalur TCP
iptables -t nat -I POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -t nat -I POSTROUTING -s 10.9.0.0/24 -o eth0 -j MASQUERADE
iptables-save

# iptables-persistent
apt-get install iptables-persistent
/etc/init.d/openvpn restart

# Konfigurasi dan Setting untuk Client
mkdir clientconfig
cp /etc/openvpn/easy-rsa/keys/{white-vps.crt,white-vps.key,ca.crt,ta.key} clientconfig/
cd clientconfig


# Buat 2 file berektensi .ovpn
# nano config-udp.ovpn
# Buat config server TCP 1194
cd /etc/openvpn

cat > /etc/openvpn/config-udp.ovpn <<-END
client
dev tun
proto udp
# proto tcp ===>> hapus uncomment tanda # jika ingin menggunakan proto tcp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/config-udp.ovpn;

# pada tulisan xxx ganti dengan alamat ip address VPS anda
# Buat config server TCP 1194

cd /etc/openvpn

cat > /etc/openvpn/config-tcp.ovpn <<-END
client
dev tun
proto tcp
# proto udp ===>> hapus uncomment tanda # jika ingin menggunakan proto udp
remote xxxxxxxxx 1194
resolv-retry infinite
route-method exe
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
auth-user-pass
comp-lzo
verb 3
END

sed -i $MYIP2 /etc/openvpn/config-tcp.ovpn;

# pada tulisan xxx ganti dengan alamat ip address VPS anda 
/etc/init.d/openvpn restart

# hapus file .sh
cd
rm -f /root/openvpndebian8.sh
exit

# cek di direktori clientconfig "/etc/openvpn/easy-rsa/keys/" hrs nya ada 4 file yaitu:
# masuk ke root vps kemudian arahkan ke directory "/etc/openvpn/easy-rsa/keys"
# ca.crt
# ta.key
# config-udp.ovpn
# config-tcp.ovpn
# download ke 4 file tersebut dan untuk CA input manual ke dalam config TCP dan UDP

# Test create account opevpn dengan perintah Berikut :
# "useradd -s /bin/false white-vps" ===>>> white-vps disini artinya username yg kita buat adalah white-vps
# "passwd white-vps" =====>>> masukan perintah ini untuk set password dari username white-vps tadi
# kemudian masukan passwr,,lanjut step akhir test vpn
