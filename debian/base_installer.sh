#!/bin/bash
SOURCES=/etc/apt/sources.list
SERVERNAME="localhost"
IP="127.0.0.1"
DIST=wheezy
CTRY=de
MYSQLPWD="abc123"
MYSQLROOTPWD="godmode"
if test -z "$(grep deb-src $SOURCES)"; then
  echo "Wtf, no deb-src's set? must be some getto $SOURCES" >&2
  echo fixing it,.. adding deb-src urls to $SOURCES >&2
( echo deb http://ftp.${CTRY}.debian.org/debian $DIST main
  echo deb-src http://ftp.${CTRY}.debian.org/debian $DIST main
  echo deb http://security.debian.org/ $DIST/updates main
  # echo deb-src http://security.debian.org/debian $DIST/updates main 
) >> $SOURCES
fi
cat /etc/apt/sources.list
echo grep active sources
sleep 1
grep -e "^[^#]" /etc/apt/sources.list
sleep 1
apt-get update
apt-get upgrade
sleep 1

MUSTHAVE="install vim-nox screen figlet toilet toilet-fonts aalib bsdgames sudo wget curl libaa-bin"
BASHES="install bash bash-doc bash-static bash-completion"
DEAMONS="systemd ntp"
BASHDEV="source busybox"
VERSIONCONTROL="install cvs git subversion bzr"
WEBMINDEPS="install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python"
THIRDPARTS="install p7zip-full"
WORDPRESS="install apache2 libapache2-mod-php5 php5 php5-curl php5-intl php5-mcrypt php5-mysql php5-sqlite php5-xmlrpc mysql-server mysql-client"
LAMP="mysql-server mysql-client apache2 apache2-mpm-prefork php5 php5-mysqlnd php5-adodb" 


installWebmin () { 
if test -z "$(grep download.webmin.com $SOURCES)"; then
	echo adding webmin
	(deb http://download.webmin.com/download/repository sarge contrib
	deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib)>>$SOURCES
fi
	cd ~
	wget http://www.webmin.com/jcameron-key.asc
	apt-key add jcameron-key.asc
	apt-get update
	apt-get install webmin
}

installWordpress () { 
CURRENTCONFIG="MUSTHAVE BASHES DEAMONS VERSIONCONTROL WORDPRESS"
echo Current Config:
echo $CURRENTCONFIG
sleep 1
for conf in $CURRENTCONFIG; do
	apt-get  ${!conf}
done

	echo adding wordpress
	mkdir -p /var/www/wordpress
	echo "NameVirtualHost ${IP}:80
<VirtualHost ${IP}:80>
	ServerAdmin root@127.0.0.1
	ServerName ${SERVERNAME}
	DocumentRoot /var/www/wordpress
	<Directory /var/www/>
		Options +Indexes +MultiViews # +FollowSymLinks
		AllowOverride All
		Order allow,deny
		allow from all
	</Directory>
	LogLevel warn
	ErrorLog \${APACHE_LOG_DIR}/${SERVERNAME}-error.log
	CustomLog \${APACHE_LOG_DIR}/${SERVERNAME}-access.log combined
</VirtualHost>" > /etc/apache2/sites-available/${SERVERNAME}.wordpress
	echo disabling default site, adding wordpress
	a2dissite default
	echo -e "\n\n\n"
	echo "And in the file /etc/apache2/ports.conf comment the line NameVirtualHost *:80 so that it looks like" >&2
	echo "Ctrl_D when done ;)"
	bash
	echo "Welcome back ^^"
	sleep 3
	
	echo add rewrite
	a2enmod rewrite

	echo /etc/php5/apache2/php.ini
	sleep 3
	echo "max_execution_time = 900
max_input_time = 900
memory_limit = 512M
post_max_size = 64M
upload_max_filesize = 64M
max_file_uploads = 32
default_socket_timeout = 900" 
	echo modify it NOOOW, ctrl_d when done
	bash
	echo Welcome back
	sleep 2

	/etc/init.d/apache2 restart

	a2ensite ${SERVERNAME}.wordpress

echo "CREATE DATABASE wordpress;
GRANT ALL ON wordpress.* TO wordpress@localhost IDENTIFIED BY '${MYSQLPWD}';
FLUSH PRIVILEGES" 
echo .
mysql -u root -p
echo welcome back

	apt-get install wget
	mkdir /tmp/wp
	cd /tmp/wp
	wget --content-disposition http://wordpress.org/latest.tar.gz
	tar -C /var/www -xf wordpress*.tar.gz
	chown -R www-data:www-data /var/www
	find /var/www -type f -exec chmod 0600 {} \;
	find /var/www -type d -exec chmod 0700 {} \;
	rm -rv /tmp/wp
echo ALL DONE
	/etc/init.d/apache2 restart


echo -e "\n\nWORDPRESS INSTALLED RESTARTING APACHE FOR GOOD MEASURE, VISIT\n"\
	"http://${SERVERNAME}:80\nOR\nhttp://${IP}:80\nTO FINISH INSTALLATION.\ntx,g'bye 'n ta 4 da fish"
}

installWordpress
