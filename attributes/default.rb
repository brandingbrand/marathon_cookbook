default['java']['jdk_version']            = '8'

# Marathon package
default['marathon']['version']            = '1.7.50'
default['marathon']['source']['url']      =
  "http://repos.mesosphere.com/debian/pool/main/m/marathon/systemd-marathon_#{node['marathon']['version']}_all.deb"

default['marathon']['zookeeper_server_list']              = []
default['marathon']['zookeeper_port']                     = 2181
default['marathon']['zookeeper_marathon_path']            = 'mesos'
default['marathon']['zookeeper_path']                     = 'mesos'

# Marathon user and directories
default['marathon']['user']               = 'marathon'
default['marathon']['group']              = 'marathon'
default['marathon']['home_dir']           = '/opt/marathon'
default['marathon']['config_dir']         = '/etc/default'
default['marathon']['log_dir']            = '/var/log/marathon'

# JVM flags
default['marathon']['jvm']['Xmx512m']     = true

# Marathon command line flags
default['marathon']['flags']['master']    = 'zk://localhost:2181/mesos'
