version = node['formatron_logstash']['version']

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

service 'logstash' do
  supports status: true, restart: true, reload: false
  action [ :enable, :start ]
end
