version = node['formatron_logstash']['version']
checksum = node['formatron_logstash']['checksum']
certificate = node['formatron_logstash']['certificate']
private_key = node['formatron_logstash']['private_key']

cache = Chef::Config[:file_cache_path]
deb = File.join cache, 'logstash.deb' 
deb_url = "https://download.elastic.co/logstash/logstash/packages/debian/logstash_#{version}.deb"

certificates_dir = '/etc/pki/tls/certs'
certificate_path = File.join certificates_dir, 'beats.crt'
private_keys_dir = '/etc/pki/tls/keys'
private_key_path = File.join private_keys_dir, 'beats.key'

remote_file deb do
  source deb_url
  checksum checksum
  notifies :install, 'dpkg_package[logstash]', :immediately
end

dpkg_package 'logstash' do
  source deb
  action :nothing
  notifies :restart, 'service[logstash]', :delayed
end

directory certificates_dir do
  recursive true
end

file certificate_path do
  content certificate
  notifies :restart, 'service[logstash]', :delayed
end

directory private_keys_dir do
  recursive true
end

file private_key_path do
  content private_key
  notifies :restart, 'service[logstash]', :delayed
end

template '/etc/logstash/conf.d/01-beats-input.conf' do
  variables(
    certificate: certificate_path,
    private_key: private_key_path
  )
  notifies :restart, 'service[logstash]', :delayed
end

cookbook_file '/etc/logstash/conf.d/10-syslog.conf' do
  notifies :restart, 'service[logstash]', :delayed
end

cookbook_file '/etc/logstash/conf.d/30-beats-output.conf' do
  notifies :restart, 'service[logstash]', :delayed
end

service 'logstash' do
  supports status: true, restart: true, reload: false
  action [ :enable, :start ]
end
