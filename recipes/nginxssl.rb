#
# Cookbook Name:: jenkins
# Recipe:: nginxssl
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

package "epel-release" do
    action :install
end

yum_package "nginx" do
    action :install
end

service 'nginx' do
  supports :restart => true, :start => true
  action :enable
end

file '/etc/nginx/conf.d/default.conf' do
    action :delete
end

directory '/etc/nginx/certs' do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
end

template '/etc/nginx/certs/ssl.cert' do
    source 'ssl.cert.erb'
    mode '0440'
    owner 'root'
    group 'root'
    internalCA = Chef::EncryptedDataBagItem.load("internal-ca", node['fqdn'])
    variables({
      :internal_ssl_cert => internalCA['certificate']
      })
    notifies :restart, 'service[nginx]', :delayed
end

template '/etc/nginx/certs/ssl.key' do
    source 'ssl.key.erb'
    mode '0440'
    owner 'root'
    group 'root'
    internalCA = Chef::EncryptedDataBagItem.load("internal-ca", node['fqdn'])
    variables({
      :internal_ssl_key => internalCA['privateKey']
      })
    notifies :restart, 'service[nginx]', :delayed
end

template '/etc/nginx/conf.d/jkvhost.conf' do
    source 'jkvhost.conf.erb'
    mode '0644'
    owner 'root'
    group 'root'
    notifies :restart, 'service[nginx]', :delayed
end