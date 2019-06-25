#
# Cookbook Name:: marathon
# Recipe:: install
#

remote_file "#{Chef::Config[:file_cache_path]}/marathon.deb" do
  source  node['marathon']['source']['url']
  action :create
end

dpkg_package 'marathon' do
  source "#{Chef::Config[:file_cache_path]}/marathon.deb"
end
