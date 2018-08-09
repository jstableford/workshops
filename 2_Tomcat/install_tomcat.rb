yum_package 'java-1.7.0-openjdk-devel' do
  options='--nogpgcheck'
  action :install
end

group 'tomcat' do
	action :create
end

user 'tomcat' do
	action :create
	shell '/sbin/nologin'
	gid 'tomcat'
	comment 'Tomcat User'
	system true
	manage_home false
end

remote_file '/tmp/apache-tomcat-8.5.32.tar.gz' do
  source 'http://apache.cs.utah.edu/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

directory '/opt/tomcat' do
	owner 'tomcat'
	group 'tomcat'
	mode '0755'
	action :create
end

bash 'untar tomcat' do
	cwd '/tmp'
	code <<-EOH
		sudo tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
		EOH
	end

execute 'chown /opt/tomcat' do
	command "chgrp -R tomcat /opt/tomcat"
	user 'root'
	action :run
end

execute 'chmod -R g+r conf' do
	user 'root'
	cwd '/opt/tomcat'
	command "sudo chmod -R g+r conf"
end

execute 'chmod g+x conf' do
	user 'root'
	cwd '/opt/tomcat'
	command "chmod g+x conf"
end

execute 'hown -R tomcat webapps/ work/ temp/ logs/' do
	user 'root'
	cwd '/opt/tomcat'
	command "chown -R tomcat webapps/ work/ temp/ logs/"
end

systemd_unit 'tomcat.service' do
	content IO.read('/home/vagrant/jstableford/recipes/tomcat.service')
	action [:create, :enable, :start]
end

execute 'wait for Tomcat' do
	command 'sleep 30'
end
http_request 'local_tomcat' do
	url 'http://localhost:8080'
	action :get
end