#!/bin/bash
#

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";

#detail nama perusahaan
country=ID
state=Banten
locality=Serang
organization=White-vps
organizationalunit=IT
commonname=White-vps.com
email=dayatdacung@gmail.com

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl & php5
apt-get update
apt-get -y -f install apache2
apt-get -y install wget curl
apt-get -y install nginx php5 php5-fpm 
apt-get -y install nginx php5 php5-cli 
apt-get -y install nginx php5 php5-mysql 
apt-get -y install nginx php5 php5-mcrypt

# install essential package
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.githubusercontent.com/Dacung555/setup-ssh-dan-vpn/master/sources.list.debian7"
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
sh -c 'echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list'
wget -qO - http://www.webmin.com/jcameron-key.asc | apt-key add -

# update
apt-get update
apt-get install ca-certificates

# install neofetch
echo "deb http://dl.bintray.com/dawidd6/neofetch jessie main" | sudo tee -a /etc/apt/sources.list
curl -L "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" -o Release-neofetch.key && apt-key add Release-neofetch.key && rm Release-neofetch.key
apt-get update
apt-get install neofetch

echo "clear" >> .bashrc
echo 'echo -e "Selamat datang di server $HOSTNAME"' >> .bashrc
echo 'echo -e "Script mod by Partner white-vps"' >> .bashrc
echo 'echo -e "Ketik menu untuk menampilkan daftar perintah"' >> .bashrc
echo 'echo -e ""' >> .bashrc

# install webserver
cd
sudo apt-get install nginx
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://ocs-deb8.000webhostapp.com/vpnssh/nginx.conf"
mkdir -p /home/vps/public_html
echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://ocs-deb8.000webhostapp.com/vpnssh/vps.conf"
/etc/init.d/nginx restart

# install openvpn
# cd
# sudo apt-get install openvpn
# wget -O /etc/openvpn/openvpn.tar "https://ocs-deb8.000webhostapp.com/vpnssh/openvpn-debian.tar"
# cd /etc/openvpn/
# tar xf openvpn.tar
# wget -O /etc/openvpn/1194.conf "https://ocs-deb8.000webhostapp.com/vpnssh/1194.conf"
# service openvpn restart
# sysctl -w net.ipv4.ip_forward=1
# sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
# iptables -t nat -I POSTROUTING -s 192.168.100.0/8 -o eth0 -j MASQUERADE
# iptables-save > /etc/iptables_yg_baru_dibikin.conf
# wget -O /etc/network/if-up.d/iptables "https://ocs-deb8.000webhostapp.com/vpnssh/iptables-restore"
# chmod +x /etc/network/if-up.d/iptables
# /etc/init.d/openvpn restart

# konfigurasi openvpn
# cd /etc/openvpn/
# wget -O /etc/openvpn/client.ovpn "https://ocs-deb8.000webhostapp.com/vpnssh/client-1194.conf"
# sed -i $MYIP2 /etc/openvpn/client.ovpn;
# cp client.ovpn /home/vps/public_html/

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://ocs-deb8.000webhostapp.com/vpnssh/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "https://ocs-deb8.000webhostapp.com/vpnssh/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# setting port ssh
cd
sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
/etc/init.d/ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=1080/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 80"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart

# install squid3
cd
apt-get -y install squid3
wget -O /etc/squid3/squid.conf "https://ocs-deb8.000webhostapp.com/vpnssh/squid3.conf"
sed -i $MYIP2 /etc/squid3/squid.conf;
/etc/init.d/squid re3start

# install webmin
cd
apt-get -y update && apt-get -y upgrade
apt-get -y install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.831_all.deb
dpkg --install webmin_1.831_all.deb
sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
rm -f webmin_1.831_all.deb
/etc/init.d/webmin restart

# install stunnel
apt-get install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1


[dropbear]
accept = 443
connect = 127.0.0.1:1080

END

#membuat sertifikat
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

#konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# install fail2ban
apt-get -y install fail2ban;service fail2ban restart


# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# download script
cd /usr/bin
wget -O menu "https://ocs-deb8.000webhostapp.com/vpnssh/menu.sh"
wget -O usernew "https://ocs-deb8.000webhostapp.com/vpnssh/usernew.sh"
wget -O trial "https://ocs-deb8.000webhostapp.com/vpnssh/trial.sh"
wget -O hapus "https://ocs-deb8.000webhostapp.com/vpnssh/hapus.sh"
wget -O cek "https://ocs-deb8.000webhostapp.com/vpnssh/user-login.sh"
wget -O member "https://ocs-deb8.000webhostapp.com/vpnssh/user-list.sh"
wget -O resvis "https://ocs-deb8.000webhostapp.com/vpnssh/resvis.sh"
wget -O speedtest "https://ocs-deb8.000webhostapp.com/vpnssh/speedtest_cli.py"
wget -O info "https://ocs-deb8.000webhostapp.com/vpnssh/info.sh"
wget -O about "https://ocs-deb8.000webhostapp.com/vpnssh/about.sh"

echo "0 0 * * * root /sbin/reboot" > /etc/cron.d/reboot

chmod +x menu
chmod +x usernew
chmod +x trial
chmod +x hapus
chmod +x cek
chmod +x member
chmod +x resvis
chmod +x speedtest
chmod +x info
chmod +x about

# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/stunnel4 restart
/etc/init.d/squid3 restart
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
rm -rf ~/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Include:" | tee log-install.txt
echo "===========================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenSSH  : 22, 143"  | tee -a log-install.txt
echo "Dropbear : 109, 80"  | tee -a log-install.txt
echo "SSL      : 443"  | tee -a log-install.txt
echo "Squid3   : 80, 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo "nginx    : 81"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "menu      : Menampilkan daftar perintah yang tersedia"  | tee -a log-install.txt
echo "usernew   : Membuat Akun SSH"  | tee -a log-install.txt
echo "trial     : Membuat Akun Trial"  | tee -a log-install.txt
echo "hapus     : Menghapus Akun SSH"  | tee -a log-install.txt
echo "cek       : Cek User Login"  | tee -a log-install.txt
echo "member    : Cek Member SSH"  | tee -a log-install.txt
echo "resvis    : Restart Service dropbear, webmin, squid3, stunnel4, vpn, ssh)"  | tee -a log-install.txt
echo "reboot    : Reboot VPS"  | tee -a log-install.txt
echo "speedtest : Speedtest VPS"  | tee -a log-install.txt
echo "info      : Menampilkan Informasi Sistem"  | tee -a log-install.txt
echo "about     : Informasi tentang script auto install"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : http://$MYIP:10000/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Original Script by partner white-vps.com"  | tee -a log-install.txt
echo "Modified by white-vps"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "VPS AUTO REBOOT TIAP JAM 12 MALAM"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==========================================="  | tee -a log-install.txt
cd
rm -f /root/deb8.sh
