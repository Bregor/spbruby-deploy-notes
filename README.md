# Install environment (necessary apps and gnome3 shell)
    # add-apt-repository ppa:chris-lea/node.js
    # apt-get update
    # apt-get dist-upgrade
    # apt-get install -y zlib1g libopenssl-ruby libdbm-ruby libgdbm-ruby libgif4 readline-common libreadline-ruby byacc build-essential automake autoconf sqlite3  mysql-server nodejs  curl 

    
Dev libraries
    # apt-get install -y libxslt-dev libxml2-dev libmysqlclient15-dev libpq-dev libqt4-dev libsqlite3-dev libreadline-dev libyaml-dev libonig-dev zlib1g-dev libexpat1-dev libssl-dev

# Install RVM
    $ bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)

Append RVM function setup to your .bash_profile:
    $ echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile

# Installing and patching Ruby
    $ curl https://raw.github.com/gist/1008945/7532898172cd9f03b4c0d0db145bc2440dcbb2f6/load.patch > /tmp/load.patch
    $ rvm get head
    $ rvm reload
    $ rvm cleanup all
    $ rvm install ruby-1.9.2-p180 --patch /tmp/load.patch -n patched
    $ rvm use ruby-1.9.2-p180-patched --default

# My configuration
    # add-apt-repository ppa:gnome3-team/gnome3
    # apt-get install -y chromium-browser gnome-shell zsh ubuntu-restricted-addons  ubuntu-restricted-extras


# Install oh-my-zsh
    $ wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

Check your preferences in ~/.zshrc and change console shell
    $ zsh

# Update SSO client for Ubuntu One compatibility with gnome3
Check SSO client version > 1.3.1
If not download and install .deb 
https://launchpad.net/ubuntu/+archive/primary/+files/ubuntu-sso-client_1.3.1-0ubuntu1_all.deb

