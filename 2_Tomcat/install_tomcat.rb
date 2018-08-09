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
	content "
	[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target"
action [:create, :enable, :start]
end
execute 'wait for Tomcat' do
	command 'sleep 30'
end
http_request 'local_tomcat' do
	url 'http://localhost:8080'
	action :get
end