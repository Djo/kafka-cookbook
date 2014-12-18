#
# Cookbook Name:: kafka
# Recipe:: mirror_maker
#

include_recipe 'kafka::_defaults'
include_recipe 'kafka::_setup'
include_recipe 'kafka::_install'

kafka_user node.mirror_maker.user do
  group node.mirror_maker.group
end

directory node.mirror_maker.log_dir do
  owner node.mirror_maker.user
  group node.mirror_maker.group
  mode '755'
  recursive true
end

node.mirror_maker.consumers.each do |config_file, options|
  template ::File.join(node.mirror_maker.config_dir, config_file) do
    source 'source_cluster_consumer.properties.erb'
    owner node.mirror_maker.user
    group node.mirror_maker.group
    mode '644'
    variables options: options
  end
end

template ::File.join(node.mirror_maker.config_dir, node.mirror_maker.producer.config_file) do
  source 'target_cluster_producer.properties.erb'
  owner node.mirror_maker.user
  group node.mirror_maker.group
  mode '644'
  variables options: node.mirror_maker.producer
end

kafka_script 'Prepare environment for Kafka MirrorMaker' do
  name 'mirror_maker'
  main_class mirror_maker_args
  options node.mirror_maker
end

service 'mirror_maker' do
  provider kafka_init_opts[:provider]
  supports start: true, stop: true, restart: true, status: true
  action kafka_service_actions
end
