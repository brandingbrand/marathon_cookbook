#
# Cookbook Name:: marathon
# Recipe:: service
#

# template "/lib/systemd/system/marathon.service" do
#   source "marathon.systemd.erb"
#   mode "0644"
#   user "root"
#   owner "root"
#   action :create
# end

# service 'marathon' do
#     user 'root'
#     provider Chef::Provider::Service::Systemd
# end

poise_service 'marathon' do
  user 'root'
  command ::File.join(node['marathon']['home_dir'], 'wrapper')
end
