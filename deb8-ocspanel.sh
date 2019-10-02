#!/bin/bash
#

# install OCS PANEL

echo "==================  sedang melakukan setup OCS PANEL ... ===================="
echo "======================================================================================"

echo "......................................................................................"
echo "......................................................................................"

echo "======================================================================================"
echo "======================================================================================"

echo -en "\n\n"

cd /usr/bin
mysql -u root -p
# CREATE DATABASE IF NOT EXISTS OCSPANEL;EXIT;
apt-get -y install git
cd /home/vps/public_html
git init
git remote add origin https://github.com/Dacung555/ocspanel.git
git pull origin master
chmod 777 /home/vps/public_html/config
chmod 777 /home/vps/public_html/config/config.ini
chmod 777 /home/vps/public_html/config/route.ini
apt-get -y -f install libxml-parser-perl
cd

echo "......................................................................................"
echo "......................................................................................"

echo "======================================================================================"
echo "======================================================================================"

echo -en "\n\n"

# Sekarang kita harus menginstall OCS Panel melalui browser untuk mengatur database, user admin, dan passwordnya

echo "sedang malakukan seting ocs untuk mengatur database, user admin, dan passwordnya ....."
echo "======================================================================================"

echo "......................................................................................"
echo "......................................................................................"

echo "======================================================================================"
echo "======================================================================================"

echo -en "\n\n"

# http://139.59.108.159:85/
# Lakukan setting seperti berikut:

# DATABASE
# Database Host: localhost (WAJIB!)
# Database Name: OCSPANEL (WAJIB!)
# Database User: root (WAJIB!) 
# Database Pass: Password MySQL yang telah dibuat tadi

# ADMIN LOGIN
# Username: Zeph
# Password Baru: Isikan dengan password OCS yang diinginkan
# Masukkan Ulang Password: Input ulang password
# rm -R /home/vps/public_html/installation
# setting XML webmin http://139.59.108.159:10000

echo "......................................................................................"
echo "......................................................................................"

echo "======================================================================================"
echo "======================================================================================"

echo -en "\n\n"
