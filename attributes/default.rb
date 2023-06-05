# default directories
default['gns3']['app_dir'] = '/opt/gns3'
default['gns3']['log_dir'] = '/var/log/gns3'

# based on the server_port and number of instances combination
# the first instance will listen on server_port
# the second instance will listen on server_port +1, etc
default['gns3']['instances'] = 1
default['gns3']['server_port'] = 3080

# the console ports are calculate per instance
# first instance 6000 - 6399
# second instance 6300 - 6599
default['gns3']['console_port_start'] = 6000
default['gns3']['console_port_count'] = 300

# use authentication
default['gns3']['authentication']['enabled'] = true
default['gns3']['authentication']['data_bag'] = 'gns3'
