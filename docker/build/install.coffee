require 'shelljs/global'

# Link node
ln '-s', '/usr/bin/nodejs', '/usr/bin/node'

# Disable ssh
rm '-rf', '/etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh'

# Install consul
cp 'consul', '/usr/local/bin/consul'
mkdir '/etc/service/consul'
cp 'consul.sh', '/etc/service/consul/run'
mkdir '/etc/service/consul/control'
cp 'consul-down.sh', '/etc/service/consul/control/t'
'2'.to '/etc/container_environment/GOMAXPROCS'
mkdir '/consul-data'

# Volume to read configuration data from.
mkdir '/consul'
