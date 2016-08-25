#
# Cookbook Name:: wordpress
# Recipe:: setup
#
# Copyright (c) 2016 The Authors, All Rights Reserved.



include_recipe 'selinux::permissive'

##GIT
package 'git' do
  action :install
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


directory node['wordpress']['wp_path'] do
  mode '0755'
  action :create
end

# execute 'permissions' do
#   command "chown -R apache:apache #{node['wordpress']['wp_path']}"
#   notifies :restart , 'service[httpd]'
# end
