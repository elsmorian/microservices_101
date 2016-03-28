#!/usr/bin/env node

var amqp = require('amqplib/callback_api');
var secs = 2;

console.log("--------------------------------");
console.log("donut minion v1.0 ready to rock!");
console.log("--------------------------------");



amqp.connect('amqp://' +process.env.RABBITMQ_USERNAME + ':' + process.env.RABBITMQ_PASSWORD +'@rabbitmq.cloud66.local', function(err, conn) {
  conn.createChannel(function(err, ch) {

    ch.assertQueue('bakery.donut.order', {durable: true});
    chdone.assertQueue('bakery.donut.order.done', {durable: true});

    ch.prefetch(1);
    console.log(process.env.HOSTNAME + ":-- [*] Waiting for donut back orders (backing time = " + secs + ")");
    ch.consume(q, function(msg) {
      console.log(process.env.HOSTNAME + ":-- [.] Start backing a '#{flavour}' donut");
      console.log(" [x] Received %s", msg.content.toString());
      setTimeout(function() {
        console.log(process.env.HOSTNAME + ":-- [.] Start backing a '#{flavour}' donut done");
        ch.ack(msg);
        chdone.sendToQueue(q, new Buffer(msg), {persistent: true});
    
      }, secs * 1000);
    }, {noAck: false});
  });
});