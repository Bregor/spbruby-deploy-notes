# Primary Settings
## Change root password
    # apt-get install apg
    $ apg -m64
    # passwd root

## Add admin user
    # useradd -g admin -d /home/spbruby -m -s /bin/bash spbruby
    # passwd spbruby
    # visudo
Add following:
    %admin ALL NOPASSWD:ALL


## Public key auth
    local$ cat .ssh/id_rsa.pub
    remote$ mkdir .ssh
    remote$ cat > .ssh/authorized_keys
    remote$ chmod 600 .ssh/authorized_keys
    remote$ chmod 700 .ssh

## Configure OpenSSH
Update */etc/ssh/sshd_config* with:
      Port 22222
      PermitRootLogin = No
      AllowUsers spbruby

## Firewall
    # mkdir -p /var/lib/iptables
    # cp var/lib/iptables/rules_save /var/lib/iptables/
Add to main interface settings in */etc/network/interfaces*:
    pre-up /sbin/iptables-restore < /var/lib/iptables/rules_save

## Update base system
    # apt-get update
    # apt-get dist-upgrade

# User shell settings
## Colors, aliases, git-branch, etc
    # apt-get install bash-completion
Add to *~/.bash_profile*:

    if [ -f /etc/bash_completion ]; then
      . /etc/bash_completion
    fi

    # set a fancy prompt (non-color, unless we know we "want" color)
    if [[ ${EUID} == 0 ]] ; then	
      PS1='\[\033[01;31m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] '
    else
      PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w `git branch 2>&1 | grep "*" | awk -F" " "{print \\\$2}"`\$\[\033[00m\] '
    fi

    if [ -f ~/.bash_aliases ]; then
      . ~/.bash_aliases
    fi
Add to *~/.bash_aliases*:
    alias ls='ls --color=auto'
    alias ll='ls -l'
    alias la='ls -al'
    alias l='ls -CF'
    alias grep='grep --color'

## Locale settings
Add to *~/.bash_profile*
    export LANG=ru_RU.UTF-8
    export LC_MESSAGES=C

# Primary Software Install
 
## Prerequisites
    # apt-get install -y build-essential git-core git-svn automake autoconf

## RubyEE
    # apt-get install -y libexpat1-dev zlib1g zlib1g-dev libyaml-dev libonig-dev libopenssl-ruby libssl-dev libdbm-ruby libgdbm-ruby libgif4 readline-common libreadline-dev libreadline-ruby byacc
    # chgrp admin /usr/local/src/
    # chmod g+ws /usr/local/src/
    $ cd /usr/local/src/
    $ git clone git://github.com/FooBarWidget/rubyenterpriseedition187-330.git
    $ ln -s rubyenterpriseedition187-330 ruby
    $ cd ruby
    $ git checkout -b 2011.03 release-2011.03
    $ autoconf 
    $ ./configure 
    $ make -j`expr $(grep processor /proc/cpuinfo | wc -l) + 1`
    # make install

## RubyGems
    $ wget http://production.cf.rubygems.org/rubygems/rubygems-1.7.2.tgz
    $ tar xvf rubygems-1.7.2.tgz
    $ cd rubygems-1.7.2
    # ruby setup.rb
    # gem in rubygems-update bundler --no-ri --no-rdoc

## Rails
    # apt-get install -y sqlite3 libsqlite3-dev mysql-server libmysqlclient15-dev postgresql-8.4 postgresql-server-dev-8.4 libpq-dev
    # gem in sqlite3-ruby mysql pg thin rails  --no-ri --no-rdoc

## NGINX and Phusion Passenger
    # apt-get install -y libpcre3 libpcre3-dev libperl-dev libxml2-dev libxml2 libxslt-dev curl-ssl libcurl4-openssl-dev
    $ cd /usr/local/src
    $ wget http://sysoev.ru/nginx/nginx-1.0.5.tar.gz && tar xvf nginx-1.0.5.tar.gz && ln -nfs nginx-1.0.5 nginx && rm -f nginx-1.0.5.tar.gz
    $ wget http://citylan.dl.sourceforge.net/project/pcre/pcre/8.12/pcre-8.12.tar.bz2 && tar xvf pcre-8.12.tar.bz2 && ln -nsf pcre-8.12 pcre && rm -f pcre-8.12.tar.bz2
    $ git clone git://github.com/FooBarWidget/passenger.git
    $ cd passenger
    # ./bin/passenger-install-nginx-module  --auto --prefix=/opt/nginx --nginx-source-dir=/usr/local/src/nginx --extra-configure-flags='--with-http_flv_module --with-http_realip_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-http_stub_status_module --with-poll_module --with-pcre=/usr/local/src/pcre --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --user=www-data --group=www-data'


# Configure RDBMS
## PostgreSQL related stuff
* Access only from localhost

Add to the */etc/postgresql/8.4/main/postgresql.conf*
    listen_addresses = 'localhost'
* Easy access from localhost

Add to */etc/postgresql/8.4/main/pg_hba.conf*
    # TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
    # Database administrative login by UNIX sockets
    # "local" is for Unix domain socket connections only
                                                                                                                                                   
    # local   all         postgres                          ident
    local   all         all                               trust


* Adding user and database

Run:
    $ psql -Upostgres
    postgres=# ALTER ROLE postgres ENCRYPTED PASSWORD 'supersecurerootpassword';
    postgres=# CREATE ROLE spbruby NOSUPERUSER LOGIN ENCRYPTED PASSWORD 'superpupermegapasword';
    postgres=# CREATE DATABASE spbruby ENCODING 'UTF-8' OWNER spbruby;

## MySQL related stuff
First run:
    # mysql_secure_installation
Fill the questionnaire:

**Enter current password for root (enter for none):** 

**Change the root password? [Y/n]** *n*

** ... skipping.**

** Remove anonymous users? [Y/n]** *y* 

** ... Success!**

** Disallow root login remotely? [Y/n]** *y*

** ... Success!**

**Remove test database and access to it? [Y/n]** *y*

** - Dropping test database...**

** ... Success!**

** - Removing privileges on test database...**

** ... Success!**

**Reloading the privilege tables will ensure that all changes made so far will take effect immediately.**

**Reload privilege tables now? [Y/n]** *y* 

** ... Success!**

Then run:
    $ mysql -uroot -p
    mysql> CREATE DATABASE spbruby;
    mysql> GRANT ALL ON spbruby.* TO spbruby@localhost IDENTIFIED BY 'superpuperpassword';
    mysql> FLUSH PRIVILEGES;

# Configure SSL
## Create self-signed CA
    # apt-get install -y openvpn
    # mv /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/ssl/easy-rsa
    # apt-get remove -y openvpn
    # apt-get -y autoremove
    $ cd /etc/ssl/easy-rsa
Update *vars* file with following:
    export KEY_COUNTRY="RU"
    export KEY_PROVINCE="RU"
    export KEY_CITY="Saint Petersburg"
    export KEY_ORG="spbruby.org"
    export KEY_EMAIL="security@spbruby.org"
Import *vars* to current shell:
    # . vars
Initialize the $KEY_DIR directory:
    # ./clean-all
Build a root certificate
    # ./build-ca
## Create server-side certificates
Build Diffie-Hellman parameters for the server side of an SSL/TLS connection.
    # ./build-dh
Make a certificate/private key pair using a locally generated root certificate.
    # ./build-key-server spbruby.org
    # ./build-key-server mail.spbruby.org

# Configure nginx
## Vhosts management
Place utils for manage nginx vhosts to */usr/local/bin/* and make them executable:
    $ chmod +x ./usr/local/bin/*
    # mv ./usr/local/bin/* /usr/local/bin/
## Configuration
Then place *./opt/nginx/conf/nginx.conf* to */opt/nginx/conf/*

After that we need to create folders for vhosts configuration
    $ cd /opt/nginx/conf
    # mkdir sites-available sites-enabled
And then place config-file for our vhost (*./opt/nginx/conf/sites-available/spbruby.org*) to */opt/nginx/conf/sites-available/*

And enable vhost:
    # nginxensite spbruby.org

# Backups
## Installation
    # gem in astrails-safe --no-rdoc --no-ri
Place safe config from *./etc/safe.rb* to */etc*
## Schedule
    # cat > /etc/cron.daily/safe
      /usr/local/bin/astrails-safe /etc/safe.rb
      ^D
    # chmod 755 /etc/cron.daily/safe
# Logs Rotation
    # apt-get install logrotate
Place *etc/logrotate.d/spbruby.org* and *etc/logrotate.d/nginx* to */etc/logrotate.d*

# Mail
## Install
    # apt-get install -y exim4-daemon-heavy dovecot-common dovecot-imapd dovecot-pop3d clamav-daemon
    # mkdir /var/log/dovecot
    # gpasswd -a clamav Debian-Exim
## DB configuration
    $ psql -Upostgres
    postgres=# CREATE ROLE mail NOSUPERUSER LOGIN ENCRYPTED PASSWORD 'mailpassword';
    postgres=# CREATE DATABASE mail ENCODING 'UTF-8' OWNER mail;
    $ psql -Upostgres mail < etc/exim4/mail_schema.pgsql
## SMTP configuration
    # cp etc/exim4/exim.conf /etc/exim4/exim.conf.template
    # cp etc/aliasdomains /etc/aliasdomains
    # /etc/init.d/exim4 restart
## IMAP4/POP3 configuration
    # cp etc/dovecot/* /etc/dovecot
    # /etc/init.d/dovecot restart
## Web interface
    # mkdir -p /var/www/mail.spbruby.org
    # chown www-data:www-data /var/www/mail.spbruby.org
    # chmod ug+ws /var/www/mail.spbruby.org
    $ cd /var/www/mail.spbruby.org
    $ mkdir conf log
    $ cd /usr/local/src
    $ wget http://sunet.dl.sourceforge.net/project/roundcubemail/roundcubemail/0.4/roundcubemail-0.4.tar.gz
    # tar xvf roundcubemail-0.4.tar.gz -C /var/www/mail.spbruby.org/
    $ cd /var/www/mail.spbruby.org/
    $ ln -s roundcubemail-0.4 public
Now we must place *opt/nginx/conf/sites-available/mail.spbruby.org* to */opt/nginx/conf/sites-available/*  
And enable it.
    # nginxensite mail.spbruby.org
# Autostart services
## Runit
### Installation
    # apt-get install -y runit
    # gem in runit-man --no-ri --no-rdoc
    # mkdir -p /etc/sv/nginx /etc/sv/spawn-fcgi/log /etc/sv/runit-man/log
### Configuration
Place runit recipes from etc/sv to system /etc/sv
    # cp -r etc/sv/* /etc/sv/
And add symlinks to /etc/service/ and /etc/init.d/ for autorun
    # for i in nginx spawn-fcgi runit-man; do ln -s /usr/bin/sv /etc/init.d/${i}; ln -s /etc/sv/${i} /etc/service/; update-rc.d ${i} defaults; done
Don't forget to enable access to runit-manager from your host
    # iptables -A INPUT -p tcp --dport 12700 -s <your-IP> -j ACCEPT
And save iptables config
    # iptables-save > /var/lib/iptables/rules_save
From now you can run runit-manager and access it via HTTP
    # sv start runit-man
or
    # /etc/init.d/runit-man start
It will be accessible on your host:12700 via HTTP
# Search
## Sphinx
### Installation
    $ wget http://www.sphinxsearch.com/downloads/sphinx-1.10-beta.tar.gz && tar xvf sphinx-1.10-beta.tar.gz && ln -nsf sphinx-1.10-beta sphinx && rm -f sphinx-1.10-beta.tar.gz
    $ cd sphinx
    $ wget http://snowball.tartarus.org/dist/libstemmer_c.tgz && tar xvf libstemmer_c.tgz && rm -f libstemmer_c.tgz
    $ ./configure --with-pgsql --without-mysql --with-libstemmer 
Use **--with-mysql --without-pgsql** in case of MySQL database
    $ make -j`expr $(grep processor /proc/cpuinfo | wc -l) + 1`
    # make install
# Monitoring
