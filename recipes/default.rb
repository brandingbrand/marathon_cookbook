#
# Cookbook Name:: marathon
# Recipe:: default
#
# Copyright (C) 2013 Medidata Solutions, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'marathon::install'

link '/usr/lib/libmesos.so' do
  to '/usr/local/lib/libmesos.so'
  not_if 'test -e /usr/local/lib/libmesos.so'  # prevent recursive symlinks
end

directory node['marathon']['home_dir'] do
  owner node['marathon']['user']
  group node['marathon']['group']
  mode 00755
  recursive true
  action :create
end

directory "#{node['marathon']['home_dir']}/environment" do
  owner node['marathon']['user']
  group node['marathon']['group']
  mode 00755
  action :create
end

directory node['marathon']['config_dir'] do
  owner node['marathon']['user']
  group node['marathon']['group']
  mode 00755
  action :create
end

directory node['marathon']['log_dir'] do
  owner node['marathon']['user']
  group node['marathon']['group']
  mode 00755
  action :create
end

zk_server_list = []
zk_port = nil
zk_path = nil
zk_master_option = nil
zk_option = nil

if node['marathon']['zookeeper_server_list'].count > 0
  zk_server_list = node['marathon']['zookeeper_server_list']
  zk_port = node['marathon']['zookeeper_port']
  zk_path = node['marathon']['zookeeper_path']
  zk_marathon_path = node['marathon']['zookeeper_marathon_path']
end

if node['marathon']['zookeeper_exhibitor_discovery'] && !node['marathon']['zookeeper_exhibitor_url'].nil?
  zk_nodes = MesosHelper.discover_zookeepers_with_retry(node['marathon']['zookeeper_exhibitor_url'])

  if zk_nodes.nil?
    Chef::Application.fatal!('Failed to discover zookeepers.  Cannot continue')
  end

  zk_server_list = zk_nodes['servers']
  zk_port = zk_nodes['port']
  zk_path = node['marathon']['zookeeper_path']
  zk_marathon_path = node['marathon']['zookeeper_marathon_path']
end

# ZK multi-node syntax: zk://host1:port1,host2:port2,.../path
zk_url_list = []
zk_server_list.each do |zk_server|
  zk_url_list << "#{zk_server}:#{zk_port}"
end

# If we have been able to find zookeeper master endpoint and zookeeper hosts
# then set the command line options we'll be passing to runit
if zk_url_list.count > 0
  node.default['marathon']['options']['master'] = "zk://#{zk_url_list.join(',')}/#{zk_path}"
  node.default['marathon']['options']['zk'] = "zk://#{zk_url_list.join(',')}/#{zk_marathon_path}"
elsif node['marathon']['options']['master'].nil?
  # if we don't have a user set master or a zk configured master
  # default to local mode.
  node.default['marathon']['options']['master'] = 'local'
end

# Don't add duplicate hostname flags if the attribute is set
if node['marathon']['options']['hostname'].nil?
  if node.attribute?('ec2')    
    hostname = "#{node['ec2']['public_hostname']}"
  else
    hostname = "#{node['ipaddress']}"
  end
  node.default['marathon']['options']['hostname'] = hostname
end

template "#{node['marathon']['config_dir']}/marathon" do
  source 'config.erb'
  owner node['marathon']['user']
  group node['marathon']['group']
  mode 00755
  variables(
    opts: node['marathon']['options'],
    java_opts: node['marathon']['java_opts']
  )
  notifies :restart, 'service[marathon]', :delayed
end
