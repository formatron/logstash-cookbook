version = node['formatron_logstash']['version']
checksum = node['formatron_logstash']['checksum']
port = node['formatron_logstash']['port']

cache = Chef::Config[:file_cache_path]
deb = File.join cache, 'logstash.deb' 
deb_url = "https://download.elastic.co/logstash/logstash/packages/debian/logstash_#{version}.deb"

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

# Workaround for problems with beats plugin
# force version to 0.9.6
bash 'update_beats_plugin' do
  code <<-EOH.gsub(/^ {4}/, '')
    ./bin/plugin install --version 0.9.6 logstash-input-beats
  EOH
  cwd '/opt/logstash'
end

template '/etc/logstash/conf.d/01-beats-input.conf' do
  variables(
    port: port
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
