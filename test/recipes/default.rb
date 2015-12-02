node.default['java']['jdk_version'] = '8'
include_recipe 'java::default'

include_recipe 'formatron_logstash::default'
