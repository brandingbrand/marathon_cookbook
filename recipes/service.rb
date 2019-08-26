#
# Cookbook Name:: marathon
# Recipe:: service
#

poise_service 'marathon' do
  user 'root'
  command ::File.join(node['marathon']['home_dir'], 'wrapper')
end
