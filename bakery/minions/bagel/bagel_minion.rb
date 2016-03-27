#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require "json"
require "logger"

conn = conn = Bunny.new host: ENV['RABBITMQ_HOST'] || 'rabbitmq.cloud66.local', user: ENV['RABBITMQ_USERNAME'], pass: ENV['RABBITMQ_PASSWORD']
conn.start

ch   = conn.create_channel
work_queue = ch.queue("bakery.bagel.order", :durable => true)
work_done_queue = ch.queue("bakery.sweet.done", :durable => true)

ch.prefetch(1)
sleep_time = 1.5

logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
   "| #{msg}\n"
end

logger.info "--------------------------------"
logger.info "bagel minion v1.0 ready to rock!"
logger.info "--------------------------------"
logger.info "#{ENV['HOSTNAME']}:-- [*] Waiting for bagel back orders (backing time = #{sleep_time})"


begin
    work_queue.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, payload|
    
    # payload = {"flavour":"brown","order":"1"}
    task = JSON.parse payload
    flavour = task['flavour']
    order = task['order']

    logger.info "#{ENV['HOSTNAME']}:-- [.] Start backing a '#{flavour}' bagel"

    #the real backing start here
    sleep sleep_time

    logger.info "#{ENV['HOSTNAME']}:-- [x] Backing a '#{flavour}' bagel done"
    ch.ack(delivery_info.delivery_tag)
    work_done_queue.publish(payload, :persistent => true)
  end
rescue Interrupt => _
  conn.close
end