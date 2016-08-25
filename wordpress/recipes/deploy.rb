#
# Cookbook Name:: wordpress
# Recipe:: deploy
#
# Copyright (c) 2016 The Authors, All Rights Reserved.


#
# Cookbook Name:: wordpress
# Recipe:: wp
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

###WORDPRESS SETUP#####

app = search(:aws_opsworks_app).first
app_path = node['wordpress']['wp_path']
#app_path = "/srv/#{app['shortname']}"

Chef::Log.info("********** The app's short name is '#{app['shortname']}' **********")
Chef::Log.info("********** The app's URL is '#{app['app_source']['url']}' **********")

application app_path do
  owner 'apache'
  group 'apache'

  git app_path do
    repository app["app_source"]["url"]
    revision app["app_source"]["revision"]
  end
end


template "#{node['wordpress']['wp_path']}/wp-config.php" do
  source 'wp-config.php.erb'
  #variables(:pass => root_password['pass'])
end

execute 'permissions' do
  command "chown -R apache:apache #{node['wordpress']['wp_path']}"
  notifies :restart , 'service[httpd]'
end
