#
# Cookbook Name:: wordpress
# Recipe:: apache
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


##APACHE SETUP #####

package 'httpd' do
  action :install
end

service 'httpd' do
  action [:enable, :start]
end

template '/etc/httpd/conf/httpd.conf' do
  source 'httpd.conf.erb'
end
