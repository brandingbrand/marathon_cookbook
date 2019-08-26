#
# Cookbook Name:: marathon
# Recipe:: install
#

poise_service_user node['marathon']['user'] do
  group node['marathon']['group']
  home node['marathon']['home']
end

directory "#{node['marathon']['home_dir']}" do
  owner node['marathon']['user']
  group node['marathon']['group']
  mode 00755
  action :create
end

remote_file "#{Chef::Config[:file_cache_path]}/marathon.deb" do
  source  node['marathon']['source']['url']
  action :create
end

dpkg_package 'marathon' do
  source "#{Chef::Config[:file_cache_path]}/marathon.deb"
end
