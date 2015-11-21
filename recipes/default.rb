version = node['formatron_logstash']['version']
checksum = node['formatron_logstash']['checksum']

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

service 'logstash' do
  supports status: true, restart: true, reload: false
  action [ :enable, :start ]
end
