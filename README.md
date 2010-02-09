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
    # chgrp admin /usr/local/src/
    # chmod g+ws /usr/local/src/
    $ cd /usr/local/src/
    $ git clone git://github.com/FooBarWidget/rubyenterpriseedition187.git
    $ cd rubyenterpriseedition187/
    $ autoconf 
    $ ./configure --enable-pthread --enable-shared 
    $ make
    # make install

## RubyGems
    $ wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
    $ tar xvf rubygems-1.3.5.tgz
    $ cd rubygems-1.3.5
    # ruby setup.rb
    # gem in rubygems-update gemcutter --no-ri --no-rdoc

## Rails
    # apt-get install -y sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql-8.4 postgresql-server-dev-8.4 libpq-dev
    # gem in sqlite3-ruby mysql pg rails thin  --no-ri --no-rdoc

## NGINX and Phusion Passenger
    # apt-get install -y libpcre3 libpcre3-dev libperl-dev libxml2-dev libxml2 libxslt-dev
    $ cd /usr/local/src
    $ wget http://sysoev.ru/nginx/nginx-0.7.65.tar.gz
    $ tar xvf nginx-0.7.65.tar.gz
    $ ln -s nginx-0.7.65 nginx
    $ git clone git://github.com/FooBarWidget/passenger.git
    $ cd passenger
    # ./bin/passenger-install-nginx-module

**Automatically download and install Nginx?**

...

**Enter your choice (1 or 2) or press Ctrl-C to abort:**

*Choose 2 and press enter*

**Where is your Nginx source code located?**

**Please specify the directory:** */usr/local/src/nginx*

**Please specify a prefix directory** *[/opt/nginx]:*

**Extra arguments to pass to configure script:** *--with-http_dav_module --with-http_flv_module --with-http_perl_module --with-http_realip_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-pcre --with-poll_module --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --user=www-data --group=www-data*

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
    postgres=# CREATE DATABASE spbruby OWNER spbruby;

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
    # apt-get install openvpn
    # mv /usr/share/openvpn/easy-rsa /etc/ssl/
    # apt-get remove openvpn
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
## Autostart
Place *./etc/init.d/nginx* to */etc/init.d/*
Make them executable
    # chmod 755 /etc/init.d/nginx
And ready to autostart
    # update-rc -f nginx default
## Vhosts management
Place utils for manage nginx vhosts to */usr/local/bin/* and make them executable:
    # chmod +x ./usr/local/bin/*
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
    # gem in astrails-safe --no-rdoc --no-ri
Place safe config from *./etc/safe.rb* to */etc*

# Logs (logrotate ?)
# Monitoring
# Deployment ?
