<?php
include(__DIR__ . '/config.php');
use PhpAmqpLib\Connection\AMQPStreamConnection;
use PhpAmqpLib\Message\AMQPMessage;

$connection = new AMQPStreamConnection(HOST, PORT, USER, PASS, VHOST);
$channel = $connection->channel();

$channel->queue_declare('bakery.spacecake.order', false, true, false, false);
$channel->queue_declare('bakery.sweet.done', false, true, false, false);

echo '--------------------------------', "\n";
echo 'bagel spacecake v1.0 ready to rock!', "\n";
echo '--------------------------------', "\n";
echo $_ENV['HOSTNAME'] . ':-- [*] Waiting for bagel back orders (backing time = 7)', "\n";

function process_message($message) {
  global $channel;
  echo $_ENV['HOSTNAME'] . ':-- [.] Start backing a spacecake', "\n";
  sleep(2);
  echo $_ENV['HOSTNAME'] . ':-- [x] Backing a spacecake done', "\n";
  $message->delivery_info['channel']->basic_ack($message->delivery_info['delivery_tag']);
  $response_message = new AMQPMessage($message->body);
  $channel->basic_publish($response_message, '', 'bakery.sweet.done');
};

$channel->basic_qos(null, 1, null);
$channel->basic_consume('bakery.spacecake.order', 'consumer', false, false, false, false, 'process_message');

while(count($channel->callbacks)) {
    $channel->wait();
}

$channel->close();
$connection->close();
?>