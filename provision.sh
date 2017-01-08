#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
NAME='myproject'
PASSWORD='rootpass'

# create project folder
sudo mkdir "/var/www/project"

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install apache 2.5 and php 5.5
sudo apt-get install -y apache2-mpm-prefork
sudo apt-get install -y php5 php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-pspell php5-recode php5-sqlite php5-tidy php5-xmlrpc php5-xsl

# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install php5-mysql

# install phpmyadmin and give password(s) to installer
#for simplicity I'm using the same password for mysql and phpmyadmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

# setup hosts file
echo "<VirtualHost *:80>" >> /etc/apache2/sites-available/000-default.conf
echo "  ServerName ${NAME}.ga" >> /etc/apache2/sites-available/000-default.conf
echo "  ServerAdmin admin@${NAME}.ga" >> /etc/apache2/sites-available/000-default.conf
echo "  <Directory />" >> /etc/apache2/sites-available/000-default.conf
echo "      Options Indexes FollowSymLinks" >> /etc/apache2/sites-available/000-default.conf
echo "      AllowOverride all" >> /etc/apache2/sites-available/000-default.conf
echo "      Require all granted" >> /etc/apache2/sites-available/000-default.conf
echo "  </Directory>" >> /etc/apache2/sites-available/000-default.conf
echo "  DocumentRoot /var/www/project/web/" >> /etc/apache2/sites-available/000-default.conf
echo "  ErrorLog ${APACHE_LOG_DIR}/${NAME}_error.log" >> /etc/apache2/sites-available/000-default.conf
echo "  CustomLog ${APACHE_LOG_DIR}/${NAME}_access.log combined" >> /etc/apache2/sites-available/000-default.conf
echo "  Include conf-available/serve-cgi-bin.conf" >> /etc/apache2/sites-available/000-default.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf

mysqladmin -uroot -p${PASSWORD} create ${NAME}

# enable mod_rewrite
sudo a2enmod rewrite

# restart apache
service apache2 restart

# install git
sudo apt-get -y install git
sudo apt-get -y install curl

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
