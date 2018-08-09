#
# Cookbook:: jcookbook
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
if node['kernel']['machine'] == 'x86_64'
	yum_repository 'mongodb' do
  	description "MongoDB x86_64 repo"
    gpgcheck false
  	baseurl "http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/"
  	action :create
	end

else
        yum_repository 'mongodb' do
        description "MongoDB i686 repo"
        gpgcheck false
        baseurl "http://downloads-distro.mongodb.org/repo/redhat/os/i686/"
        action :create
        end
end
yum_package 'mongodb-org' do
  options='--nogpgcheck'
  action :install
end
service 'mongod' do
  action :start
end
