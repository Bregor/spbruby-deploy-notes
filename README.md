1. change root password
(How do you generate passwords)
# apt-get install apg
$ apg -m64
# passwd root

2. Add user, add to sudoers
# useradd -g admin -d /home/spbruby -m -s /bin/bash spbruby
# passwd spbruby

3. Copy your ssh key to the server, add ssh alias
local$ cat .ssh/id_rsa.pub
remote$ mkdir .ssh
remote$ cat > .ssh/authorized_keys
<paste>
^D
remote$ chmod 600 .ssh/authorized_keys
remote$ chmod 700 .ssh
remote# visudo
        %admin ALL NOPASSWD:ALL

4. Change SSH port, disable root logins via ssh, allow  only certain users to ssh
# emacs /etc/ssh/sshd_config
  Port 22222
  PermitRootLogin = No
  AllowUsers spbruby

5. Set up basic firewall (iptables), make it work on startup
6. Tweak bash (add color, aliases)
7. Update sources (sudo aptitude update)
# apt-get update
# apt-get dist-upgrade

8. Set the system locale
$ cat >> ~/.bash_profile
export LANG=ru_RU.UTF-8
export LC_MESSAGES=C

9. Install prerequisites
# apt-get install -y build-essential git-core git-svn automake autoconf

10. Install rubyEE
# chgrp admin /usr/local/src/
# chmod g+ws /usr/local/src/
$ cd /usr/local/src/
$ git clone git://github.com/FooBarWidget/rubyenterpriseedition187.git
$ cd rubyenterpriseedition187/
$ autoconf 
$ ./configure --enable-pthread --enable-shared 
$ make
# make install

11. Install RubyGems
$ wget http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
$ tar xvf rubygems-1.3.5.tgz
$ cd rubygems-1.3.5
# ruby setup.rb
# gem in rubygems-update gemcutter --no-ri --no-rdoc

12. Install Rails
# apt-get install -y sqlite3 libsqlite3-dev mysql-server libmysqlclient-dev
# gem in sqlite3-ruby mysql rails thin  --no-ri --no-rdoc

13. Install nginx and phusion passenger
# apt-get install -y libpcre3 libpcre3-dev libperl-dev libxml2-dev libxml2 libxslt-dev
$ cd /usr/local/src
$ wget http://sysoev.ru/nginx/nginx-0.7.65.tar.gz
$ tar xvf nginx-0.7.65.tar.gz
$ ln -s nginx-0.7.65 nginx
$ git clone git://github.com/FooBarWidget/passenger.git
$ cd passenger
# ./bin/passenger-install-nginx-module

After the message:
Automatically download and install Nginx?
...
Enter your choice (1 or 2) or press Ctrl-C to abort:

Choose 2 and press enter

Where is your Nginx source code located?

Please specify the directory: /usr/local/src/nginx
Please specify a prefix directory [/opt/nginx]: 
Extra arguments to pass to configure script: --with-http_dav_module --with-http_flv_module --with-http_perl_module --with-http_realip_module --with-http_ssl_module --with-http_sub_module --with-http_xslt_module --with-pcre --with-poll_module --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --user=www-data --group=www-data

Place http://gist.github.com/raw/292476/d8d55b21981658461580a9a02ccab8df5caf393c/nginx to /etc/init.d/nginx
# chmod 755 /etc/init.d/nginx
# update-rc -f nginx default

14. Configure mysql (postgres), (add user, disable access from the outside)
14. Configure nginx

15. Backups
16. Logs (logrotate ?)
17. Monitoring
18. Deployment ?