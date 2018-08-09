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
bash 'get_tomcat_binary' do
	cwd '/tmp'
	# try to make a dynamic URL for apache as versions change
	code <<-EOH
		wget http://apache.cs.utah.edu/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
		sudo mkdir /opt/tomcat
		sudo tar xvf apache-tomcat-8*tar.gz -C /opt/tomcat --strip-components=1
		sudo chgrp -R tomcat /opt/tomcat
		cd /opt/tomcat
		sudo chmod -R g+r conf
		sudo chmod g+x conf
		sudo chown -R tomcat webapps/ work/ temp/ logs/
		EOH
	end

systemd_unit 'tomcat.service' do
	content IO.read('/home/vagrant/jstableford/recipes/tomcat.service')
	action [:create, :enable, :start]
end

action [:create, :enable, :start]
end
execute 'wait for Tomcat' do
	command 'sleep 30'
end
http_request 'local_tomcat' do
	url 'http://localhost:8080'
	action :get
end