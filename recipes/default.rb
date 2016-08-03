#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'oracle-java::jdk8'
include_recipe 'mind1repo'

yum_package 'jenkins' do
    version '2.7-1.1'
    action :install
end

remote_directory '/var/lib/jenkins/plugins' do
    source 'plugins'
    owner 'jenkins'
    group 'jenkins'
    mode '0755'
    action :create
end

service 'jenkins' do
    supports restart: true, start: true
    action :enable
end

yum_package 'docker-engine' do
    version '1.7.1-1.el6'
    action :install
end

service 'docker' do
    action [:enable, :restart]
end

directory '/var/lib/jenkins/config' do
    owner 'jenkins'
    group 'jenkins'
    mode '0755'
    action :create
end

template '/var/lib/jenkins/config/config.xml' do
    source 'config.xml.erb'
    owner 'jenkins'
    group 'jenkins'
    mode '0664'
    action :create
    notifies :restart, 'service[jenkins]', :delayed
end

cookbook_file '/usr/local/jenkins-cli.jar' do
    source 'jenkins-cli.jar'
    owner 'jenkins'
    group 'jenkins'
    mode '0755'
    action :create
end

template '/etc/sysconfig/jenkins' do
    source 'jenkins.erb'
    owner 'root'
    group 'root'
    mode '0664'
    action :create
    notifies :restart, 'service[jenkins]', :delayed
end

execute "login_default" do
  command "sleep 18; java -jar jenkins-cli.jar -s http://localhost:8080 login --username admin --password-file /var/lib/jenkins/secrets/initialAdminPassword"
  cwd '/usr/local/'
end

execute "create_user" do
  credential = Chef::EncryptedDataBagItem.load("jenkins", "credentials")
  command "echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount(\"#{credential['user']}\", \"#{credential['password']}\")' |
java -jar jenkins-cli.jar -s http://localhost:8080 groovy ="
  cwd '/usr/local/'
end
