# create group and user profile
group 'gns3'
user 'gns3' do
  comment 'user for running gns3-server'
  gid 'gns3'
  home node['gns3']['app_dir']
  shell '/usr/bin/bash'
  action :create
end

group 'kvm' do
  action :manage
  members ['gns3']
  append true
end

# make application dir
directory node['gns3']['app_dir'] do
  owner 'gns3'
  group 'gns3'
  mode '0700'
  action :create
end

# # install gns3-server
# # needs work as we now depend on stuff from other cookbooks
# pyenv_version = node['mcc_bubble']['virtualenv']
# pyenv_root = "/usr/local/pyenv/versions/#{pyenv_version}"
#
# pyenv_pip 'gns3server' do
#   virtualenv pyenv_root
# end
#
# # link to gns3-server in /usr/bin
# link '/usr/local/pyenv/shims/gns3server' do
#   to '/usr/bin/gns3-server'
#   link_type :symbolic
# end

# ubridge manually installed
# make sure to make it is owned by root:root 
# and executable for everyone
# and set the setuid bit: chmod u+s ubridge

# fix to find qemu executable from server
link '/usr/bin/qemu-kvm' do
  to '/usr/libexec/qemu-kvm'
  link_type :symbolic
end

(1..node['gns3']['instances']).each do |instance|
  # create a service file per instance
  template "/lib/systemd/system/gns3-server#{instance}.service" do
    source 'gns3server.service.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables app_dir: node['gns3']['app_dir'],
              log_dir: node['gns3']['log_dir'],
              instance: instance
    action :create
  end

  port = node['gns3']['server_port'] + instance - 1
  console_port_start = node['gns3']['console_port_start'] + (node['gns3']['console_port_count'] * instance)
  console_port_end = console_port_start + node['gns3']['console_port_count']
  template "#{node['gns3']['app_dir']}/gns3server#{instance}.conf" do
    source 'gns3server.conf.erb'
    owner 'gns3'
    group 'gns3'
    mode '0644'
    variables port: port,
              app_dir: node['gns3']['app_dir'],
              console_port_start: console_port_start,
              console_port_end: console_port_end
    action :create
    notifies :run, 'execute[systemd-reload]', :delayed
  end

  service "gns3-server#{instance}" do
    action :start
    subscribes :reload, "file[#{node['gns3']['app-dir']}/gns3server#{instance}.conf]", :immediately
  end
end
