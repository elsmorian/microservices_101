class MessageQueue

  def initialize
    @message_queue_connection = Bunny.new host: ENV['RABBITMQ_HOST'] || 'rabbitmq.cloud66.local'
    @message_queue_connection.start()
    @message_queue_channel = @message_queue_connection.create_channel
    @message_queue = @message_queue_channel.queue("bakery.order", :durable => true)
  end

  def open?
    @message_queue_connection.open?
  end

  def publish message
    @message_queue.publish message, persistent: true
  end

end