# <!-- # Installing Middleman

# ## High-Level Instructions

# * Update apt-get
# * Install Ruby
# * Install apache
# * Configure apache
# * Restart apache
# * Install git
# * Clone the repo
# * Install Bundler
# * Install project dependencies
# * Install thin service
# * Create a new thin config for the blog and copy into /etc/thin
# * Fix the /etc/init.d/thin script to incude HOME variable
# * Start / Re-start the thin service


# ## Installation Commands

# ```
# # Update apt-get

# apt-get update
apt_update do
  action :update
end

# # Build Ruby

# apt-get install build-essential libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3
apt_package 'build-essential' do
  action :install
end
apt_package 'libssl-dev' do
  action :install
end
apt_package 'libyaml-dev' do
  action :install
end
apt_package 'libreadline-dev' do
  action :install
end
apt_package 'apache2' do
  action :install
end
apt_package 'openssl' do
  action :install
end
apt_package 'curl' do
  action :install
end
apt_package 'git-core' do
  action :install
end
apt_package 'zlib1g-dev' do
  action :install
end
apt_package 'bison' do
  action :install
end
apt_package 'libxml2-dev' do
  action :install
end
apt_package 'libxslt1-dev' do
  action :install
end
apt_package 'libcurl4-openssl-dev' do
  action :install
end
apt_package 'libsqlite3-dev' do
  action :install
end
apt_package 'nodejs' do
  action :install
end
apt_package 'sqlite3' do
  action :install
end

# mkdir ~/ruby
# cd ~/ruby
# wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz
# tar -xzf ruby-2.1.3.tar.gz
# cd ruby-2.1.3
# ./configure
# make install
# rm -rf ~/ruby


bash 'build ruby' do
  user 'root'
  code <<-EOH
  mkdir /tmp/ruby
  cd /tmp/ruby
  wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.3.tar.gz
  tar xvzf ruby-2.1.3.tar.gz
  cd ruby-2.1.3
  ./configure
  make install
  rm -rf /tmp/ruby
  EOH
  not_if '[[ -e /usr/bin/irbs ]]' #test where bin is put
end

execute 'copy executable ruby/gem' do
  command 'cp /usr/local/bin/ruby /usr/bin/ruby'
  command 'cp /usr/local/bin/gem /usr/bin/gem'
  not_if '[[ -e /usr/bin/gem ]] && [[ -e /usr/bin/ruby ]]'
  user 'root'
  action :run
end

# # Ruby may install to /usr/local/bin
# #
# # So you may need to make copies of the core commands into /usr/bin
# # cp /usr/local/bin/ruby /usr/bin/ruby
# # cp /usr/local/bin/gem /usr/bin/gem

# # Install apache

# apt-get install apache2
apt_package 'apache2' do
  action :install
end
# # Configure apache

# a2enmod proxy_http
# a2enmod rewrite
# cp blog.conf /etc/apache2/sites-enabled/blog.conf
# rm /etc/apache2/sites-enabled/000-default.conf
file '/etc/apache2/sites-enabled/blog.conf' do
  user 'root'
  group 'root'
  content %Q(

LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so

ProxyRequests Off

<Proxy *>
  Order deny,allow
  Allow from all
</Proxy>


<VirtualHost *:80>
  ServerName <%= node['ipaddress'] %>
  ServerAlias <%= node['ipaddress'] %>

  ProxyRequests Off
  RewriteEngine On
  ProxyPreserveHost On
  ProxyPass / http://localhost:3000/
  ProxyPassReverse / http://localhost:3000/

</VirtualHost>)
  action :create
end

bash 'configure apache2' do
  user 'root'
  code <<-EOH
  a2enmod proxy_http
  a2enmod rewrite
  service apache2 restart
  EOH
end
# # Restart apache

# service apache2 restart

# # Install Git

# apt-get install git
apt_package 'git' do
  action :install
end
# # Clone the repo

# git clone https://github.com/learnchef/middleman-blog.git
git 'middleman-blog' do
  repository 'https://github.com/learnchef/middleman-blog.git'
  reference 'master'
  action :checkout
  user 'vagrant'
end
# cd middleman-blog

# # Install Bundler
execute 'gem install bundler' do
  cwd '/home/vagrant/jstableford/recipes/middleman/middleman-blog'
  command 'gem install bundler'
  user 'vagrant'
  action :run
end
# gem install bundler

# # Install project dependencies

# bundle install
# > should not be run as root. So another should be created
file '/etc/init.d/thin' do
  user 'root'
  content IO.read('/home/vagrant/jstableford/recipes/middleman/thin.sh')
  action :create
end
# # Install thin service
# thin install
# /usr/sbin/update-rc.d -f thin defaults

# # Create a new thin config for the blog and copy into /etc/thin
# # SEE THE UPDATED /etc/thin/blog.conf BELOW

# # Fix the /etc/init.d/thin script to incude HOME variable
# # SEE THE UPDATED /etc/init.d/thin script BELOW

# # Start / Re-start the thin service

# service thin restart

# ```


# ## /etc/apache2/sites-enabled/blog.conf

# ```
# # /etc/apache2/sites-enabled/blog.conf

# LoadModule proxy_module modules/mod_proxy.so
# LoadModule proxy_http_module modules/mod_proxy_http.so

# ProxyRequests Off

# <Proxy *>
#   Order deny,allow
#   Allow from all
# </Proxy>


# <VirtualHost *:80>
#   ServerName <%= node['ipaddress'] %>
#   ServerAlias <%= node['ipaddress'] %>

#   ProxyRequests Off
#   RewriteEngine On
#   ProxyPreserveHost On
#   ProxyPass / http://localhost:3000/
#   ProxyPassReverse / http://localhost:3000/

# </VirtualHost>
# ```

# ## /etc/thin/blog.yml

# ```
# # /etc/thin/blog.yml
# pid: tmp/pids/thin.pid
# log: log/thin.log
# timeout: 30
# max_conns: 1024
# port: 3000
# max_persistent_conns: 512
# chdir: <%= @project_install_directory %>
# environment: development
# servers: 1
# address: 0.0.0.0
# daemonize: true
# ```

# ## /etc/init.d/thin

# ```
# # /etc/init.d/thin

# #!/bin/sh
# ### BEGIN INIT INFO
# # Provides:          thin
# # Required-Start:    $local_fs $remote_fs
# # Required-Stop:     $local_fs $remote_fs
# # Default-Start:     2 3 4 5
# # Default-Stop:      S 0 1 6
# # Short-Description: thin initscript
# # Description:       thin
# ### END INIT INFO

# # Original author: Forrest Robertson

# # Do NOT "set -e"

# DAEMON=/usr/local/bin/thin
# SCRIPT_NAME=/etc/init.d/thin
# CONFIG_PATH=/etc/thin
# HOME=<%= @home_directory %>

# # Exit if the package is not installed
# [ -x "$DAEMON" ] || exit 0

# case "$1" in
#   start)
#   HOME=$HOME $DAEMON start --all $CONFIG_PATH
#   ;;
#   stop)
#   HOME=$HOME $DAEMON stop --all $CONFIG_PATH
#   ;;
#   restart)
#   HOME=$HOME $DAEMON restart --all $CONFIG_PATH
#   ;;
#   *)
#   echo "Usage: $SCRIPT_NAME {start|stop|restart}" >&2
#   exit 3
#   ;;
# esac

# :
# ```
#  -->