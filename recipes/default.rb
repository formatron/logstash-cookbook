version = node['formatron_logstash']['version']

port = node['formatron_logstash']['port']

patterns_dir = '/etc/logstash/patterns'
nginx_patterns = File.join patterns_dir, 'nginx'

apt_repository 'logstash-2.1' do
  uri 'https://packages.elastic.co/logstash/2.1/debian'
  components ['main']
  distribution 'stable'
  key 'D88E42B4'
  keyserver 'pgp.mit.edu'
  deb_src false
end

package 'logstash' do
  version version
end

directory patterns_dir do
  recursive true
end

cookbook_file nginx_patterns do
  notifies :restart, 'service[logstash]', :delayed
end

template '/etc/logstash/conf.d/10-inputs.conf' do
  variables(
    port: port
  )
  notifies :restart, 'service[logstash]', :delayed
end

template '/etc/logstash/conf.d/20-filters.conf' do
  variables(
    patterns_dir: patterns_dir
  )
  notifies :restart, 'service[logstash]', :delayed
end

cookbook_file '/etc/logstash/conf.d/30-outputs.conf' do
  notifies :restart, 'service[logstash]', :delayed
end

service 'logstash' do
  supports status: true, restart: true, reload: false
  action [ :enable, :start ]
end
