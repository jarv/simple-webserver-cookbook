#
# Cookbook Name:: webserver
# Recipe:: default
#
# Copyright 2017, jarv

package "nginx" do
  action :install
end

service 'nginx' do
  action [ :enable, :start ]
end

template '/etc/nginx/sites-available/webserver' do
  source 'webserver.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[nginx]', :delayed
  variables({
    www_root: "#{File.dirname(node[:webserver][:index_path])}"
  })
end

# Remove the default NGINX site

link '/etc/nginx/sites-enabled/default' do
  action :delete
  notifies :restart, 'service[nginx]', :delayed
end

# Add the site for webserver

link '/etc/nginx/sites-enabled/webserver' do
  to '/etc/nginx/sites-available/webserver'
  notifies :restart, 'service[nginx]', :delayed
end

directory "#{File.dirname(node[:webserver][:index_path])}" do
  owner node[:webserver][:web_user]
  group node[:webserver][:web_user]
end

cookbook_file node[:webserver][:index_path] do
  owner node[:webserver][:web_user]
  group node[:webserver][:web_user]
  source "index.html"
  mode "0644"
end
