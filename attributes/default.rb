
default[:webserver][:index_path] = "/var/www/index.html"
case node[:platform]
when "ubuntu", "debian"
  default[:webserver][:web_user] = "www-data"
when "centos", "redhat", "amazon"
  default[:webserver][:web_user] = "nginx"
end
