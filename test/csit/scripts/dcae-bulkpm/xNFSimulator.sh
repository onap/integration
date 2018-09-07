#!/bin/bash
#This scritt will simulate xNF ftpes functionality.
#This script will automatic install vsftpd and it will make necessary changes to vsftpd.conf
sudo apt-get install vsftpd -y
sudo useradd -m -u 12345 -g users -d /home/ftpuser -s /bin/bash -p $(echo ftpuser | openssl passwd -1 -stdin) ftpuser
sudo chown root:root /home/ftpuser
sudo openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem -subj "/C=IE/ST=ftp/L=Springfield/O=Dis/CN=www.onap.org"
sudo sed -i -e '/anonymous_enable=/ s/=.*/=NO/' /etc/vsftpd.conf
sudo sed -i -e '/local_enable=/ s/=.*/=YES/' /etc/vsftpd.conf
sudo sed -i -e '/write_enable=/ s/=.*/=YES/' /etc/vsftpd.conf
sudo sed -i -e '/#write_enable=/ s/#write_enable=.*/write_enable=YES/' /etc/vsftpd.conf
sudo sed -i -e '/chroot_local_user=/ s/=.*/=YES/' /etc/vsftpd.conf
sudo sed -i -e '0,/#chroot_local_user=/ s/#chroot_local_user=.*/chroot_local_user=YES/' /etc/vsftpd.conf
sudo sed -i -e '/ssl_enable=/ s/=.*/=YES/' /etc/vsftpd.conf
sudo sed -i -e "/ssl_enable=YES/a\\allow_anon_ssl=NO" /etc/vsftpd.conf
sudo sed -i -e "/allow_anon_ssl=NO/a\\force_local_data_ssl=YES" /etc/vsftpd.conf
sudo sed -i -e "/force_local_data_ssl=YES/a\\force_local_logins_ssl=YES" /etc/vsftpd.conf
sudo sed -i -e "/force_local_logins_ssl=YES/a\\ssl_tlsv1=YES" /etc/vsftpd.conf
sudo sed -i -e "/ssl_tlsv1=YES/a\\ssl_sslv2=NO" /etc/vsftpd.conf
sudo sed -i -e "/ssl_sslv2=NO/a\\ssl_sslv3=NO" /etc/vsftpd.conf
sudo sed -i -e "/ssl_sslv3=NO/a\\require_ssl_reuse=NO" /etc/vsftpd.conf
sudo sed -i -e "/require_ssl_reuse=NO/a\\ssl_ciphers=HIGH" /etc/vsftpd.conf
sudo service vsftpd restart