#
# Cookbook Name:: marathon
# Recipe:: service
#

service 'marathon' do
    user 'root'
    provider Chef::Provider::Service::Systemd
end
