#
# Cookbook Name:: kafka
# Attributes:: mirror_maker
#

include_attribute 'kafka::default'

default.mirror_maker.log_dir = '/var/log/mirror_maker'
default.mirror_maker.config_dir = node.kafka.config_dir
default.mirror_maker.user = node.kafka.user
default.mirror_maker.group = node.kafka.group
default.mirror_maker.init_style = node.kafka.init_style
default.mirror_maker.log4j_config = 'mirror_maker.log4j.properties'

# MirrorMaker tool parameters,
# see https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=27846330
# or `bin/kafka-run-class.sh kafka.tools.MirrorMaker --help`
default.mirror_maker.parameters.whitelist = "'.*'"

# Kafka consumers to consume messages from the SOURCE clusters,
# see the template `source_cluster_consumer.properties.erb`
default.mirror_maker.consumers = {}
node.mirror_maker.consumers.each do |config_file, _|
  default.mirror_maker.consumers[config_file]['zookeeper_connection_timeout_ms'] = 6000
  default.mirror_maker.consumers[config_file]['socket_buffersize'] = 64 * 1024
  default.mirror_maker.consumers[config_file]['fetch_size'] = 300 * 1024
end

# Kafka producer to produce messages to the TARGET cluster,
# see the template `target_cluster_producer.properties.erb`
default.mirror_maker.producer.config_file = 'target_cluster_producer.properties'
default.mirror_maker.producer.producer_type = 'sync'
default.mirror_maker.producer.compression_codec = 0
default.mirror_maker.producer.serializer_class = 'kafka.serializer.DefaultEncoder'
default.mirror_maker.producer.queue_buffering_max_ms = 5000
default.mirror_maker.producer.queue_buffering_max_messages = 10000
default.mirror_maker.producer.queue_enqueue_timeout_ms = -1
default.mirror_maker.producer.batch_num_messages = 200

# AWS OpsWorks support
if node['opsworks']
  broker_instances = node.opsworks.layers.kafka.instances
  list = broker_instances.values.map { |i| "#{i['public_dns_name']}:9092" }.join(',')
  default.mirror_maker.producer.metadata_broker_list = list
else
  default.mirror_maker.producer.metadata_broker_list = 'localhost:9092'
end
