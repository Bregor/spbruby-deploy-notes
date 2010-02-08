# change root password
    # apt-get install apg
    $ apg -m64
    # passwd root

# Add user, add to sudoers
    # useradd -g admin -d /home/spbruby -m -s /bin/bash spbruby
    # passwd spbruby
    # visudo
Add following:
    %admin ALL NOPASSWD:ALL


# Copy your ssh key to the server, add ssh alias
    local$ cat .ssh/id_rsa.pub
    remote$ mkdir .ssh
    remote$ cat > .ssh/authorized_keys

# Change SSH port, disable root logins via ssh, allow  only certain users to ssh
Update /etc/ssh/sshd_config with:
      Port 22222
      PermitRootLogin = No
      AllowUsers spbruby

# Set up basic firewall (iptables), make it work on startup
    # mkdir -p /var/lib/iptables
    # cp var/lib/iptables/rules_save /var/lib/iptables/
Add to main interface settings in /etc/network/interfaces:
    pre-up /sbin/iptables-restore < /var/lib/iptables/rules_save

# Tweak bash (add color, aliases)
Add to ~/.bash_profile:

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
Add to ~/.bash_aliases:
    alias ls='ls --color=auto'
    alias ll='ls -l'
    alias la='ls -al'
    alias l='ls -CF'
    alias grep='grep --color'
# Update sources (sudo aptitude update)
    # apt-get update
    # apt-get dist-upgrade

# Set the system locale
    $ cat >> ~/.bash_profile
    export LANG=ru_RU.UTF-8
    export LC_MESSAGES=C

# Install prerequisites
    # apt-get install -y build-essential git-core git-svn automake autoconf

# Install rubyEE
    # chgrp admin /usr/local/src/
    # chmod g+ws /usr/local/src/
    $ cd /usr/local/src/
    $ git clone git://github.com/FooBarWidget/rubyenterpriseedition187.git
    $ cd rubyenterpriseedition187/
    $ autoconf 
    $ ./configure --enable-pthread --enable-shared 
    $ make
    # make install

# Install RubyGems
    $ wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
    $ tar xvf rubygems-1.3.5.tgz
    $ cd rubygems-1.3.5
    # ruby setup.rb
    # gem in rubygems-update gemcutter --no-ri --no-rdoc

# Install Rails
    # apt-get install -y sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev postgresql-8.4 postgresql-server-dev-8.4 libpq-dev
    # gem in sqlite3-ruby mysql pg rails thin  --no-ri --no-rdoc

# Install nginx and phusion passenger
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

Place ./etc/init.d/nginx to /etc/init.d/nginx
    # chmod 755 /etc/init.d/nginx
    # update-rc -f nginx default

# Configure mysql (postgres), (add user, disable access from the outside)
# Configure nginx

# Backups
# Logs (logrotate ?)
# Monitoring
# Deployment ?
