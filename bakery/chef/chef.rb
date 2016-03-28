#!/usr/bin/env ruby
# encoding: utf-8

require "bunny"
require "json"
require "logger"

conn = Bunny.new host: ENV['RABBITMQ_HOST'] || 'rabbitmq.cloud66.local', user: ENV['RABBITMQ_USERNAME'], pass: ENV['RABBITMQ_PASSWORD']
conn.start

ch   = conn.create_channel
work_queue = ch.queue("bakery.order", :durable => true)
bagel_queue = ch.queue("bakery.bagel.order", :durable => true)
spacecake_queue = ch.queue("bakery.spacecake.order", :durable => true)
donut_queue = ch.queue("bakery.donut.order", :durable => true)


ch.prefetch(1)
sleep_time = 5.0

logger = Logger.new(STDOUT)
logger.formatter = proc do |severity, datetime, progname, msg|
   "| #{msg}\n"
end

logger.info "--------------------------------"
logger.info "chef v1.2 ready to rock!"
logger.info "--------------------------------"
logger.info "#{ENV['HOSTNAME']}:-- [*] Waiting for orders"


begin
    work_queue.subscribe(:manual_ack => true, :block => true) do |delivery_info, properties, payload|
      task = JSON.parse payload
      logger.info "#{ENV['HOSTNAME']}:-- [.] Start giving order"

      if task['kind'] == 'bagel'
        task['amount'].times do |count|
           bagel_queue.publish(payload, :persistent => true)
        end
      end
      if task['kind'] == 'spacecake'
        task['amount'].times do |count|
          spacecake_queue.publish(payload, :persistent => true)
        end
      end
       if task['kind'] == 'donut'
        task['amount'].times do |count|
          donut_queue.publish(payload, :persistent => true)
        end
      end
      logger.info "#{ENV['HOSTNAME']}:-- [x] Giving orders done"
      ch.ack(delivery_info.delivery_tag)
    end
rescue Interrupt => _
  conn.close
end