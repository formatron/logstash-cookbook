def whyrun_supported?
  true
end

use_inline_resources

action :create do
  template "/etc/logstash/conf.d/20-#{new_resource.name}.conf" do
    source new_resource.template
    variables new_resource.variables
  end
end
