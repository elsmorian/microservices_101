#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require "json"
require "logger"
require "restclient"

conn = Bunny.new host: ENV['RABBITMQ_HOST'] || 'rabbitmq.cloud66.local'
conn.start

ch   = conn.create_channel
sweet_done_queue = ch.queue("bakery.sweet.done", :durable => true)

ch.prefetch(1)

logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
   "| #{msg}\n"
end

logger.info "--------------------------------"
logger.info "picker v1.0 ready to rock!"
logger.info "--------------------------------"
logger.info "#{ENV['HOSTNAME']}:-- [*] Waiting for orders"


begin
    sweet_done_queue.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, payload|
      task = JSON.parse payload
      logger.info "#{ENV['HOSTNAME']}:-- [.] Received 1 fresh baked #{task['flavour']} #{task['kind']} for customer #{task['id']}"
      #POST http://xxx/v1/orders/1/sweet/done  - curl -X POST  -H "Accept: application/json" http://192.168.99.100:8000/v1/orders/1/sweet/done 
      RestClient.post "http://counter.cloud66.local/v1/orders/#{task['id']}/sweet/done", {}, :content_type => :json, :accept => :json
      ch.ack(delivery_info.delivery_tag)
    end
rescue Interrupt => _
  conn.close
end