#
# Cookbook Name:: webserver
# Recipe:: default
#
# Copyright 2017, jarv

case node[:platform]
  when "centos", "redhat", "amazon"
  package "epel-release" do
    action :install
  end
end

package "nginx" do
  action :install
end

service 'nginx' do
  action [ :enable, :start ]
end

case node[:platform]
when "ubuntu", "debian"
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
when "centos", "redhat", "amazon"
  template '/etc/nginx/conf.d/webserver' do
    source 'webserver.erb'
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[nginx]', :delayed
    variables({
      www_root: "#{File.dirname(node[:webserver][:index_path])}"
    })
  end
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
