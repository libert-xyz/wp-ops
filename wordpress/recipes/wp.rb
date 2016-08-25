#
# Cookbook Name:: wordpress
# Recipe:: wp
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

include_recipe 'selinux::permissive'

###WORDPRESS SETUP#####


directory '/var/www' do
  mode '0755'
  action :create
end

directory node['wordpress']['wp_path'] do
  mode '0755'
  action :create
end

remote_file "/root/latest.tar.gz" do
  not_if do ::File.exists?('/root/latest.tar.gz') end
  source node['wordpress']['wp_package']
  action :create
  notifies :run, "execute[untar]", :immediately
end

execute "untar" do
  command "tar -xvzf /root/latest.tar.gz"
  notifies :run, "execute[move]", :immediately
  action :nothing
end


execute "move" do
  command "cp -r /wordpress/* #{node['wordpress']['wp_path']}"
  action :nothing
end

# execute "permissions" do
# command "chown -R apache:apache #{node['wp']['wp_path']}"
# notifies :run, "execute[template]"
# action: nothing
# end

template "#{node['wordpress']['wp_path']}/wp-config.php" do
  source 'wp-config.php.erb'
  #variables(:pass => root_password['pass'])
end

####PHP7 SETUP ###########

execute 'script' do
  command 'bash ~/setup.sh'
  action :nothing
end


execute 'php-install' do
  command 'yum install mod_php70u php70u-cli php70u-mysqlnd -y'
  action :nothing
end


execute 'curl' do
  not_if do ::File.exists?("~/setup.sh") end 
  command "curl https://setup.ius.io/ > ~/setup.sh"
  notifies :run, 'execute[script]' , :immediately
  notifies :run, 'execute[php-install]' , :immediately

end


###APACHE SETUP######

package 'httpd' do
  action :install
end

service 'httpd' do
  action [:enable, :start]
end

template '/etc/httpd/conf/httpd.conf' do
  source 'httpd.conf.erb'
end

execute 'permissions' do
  command "chown -R apache:apache #{node['wordpress']['wp_path']}"
  notifies :restart , 'service[httpd]'
end
