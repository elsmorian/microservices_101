#!/usr/bin/env node

var amqp = require('amqplib/callback_api');
var secs = 2;

console.log("--------------------------------");
console.log("donut minion v1.0 ready to rock!");
console.log("--------------------------------");

var ch_in;
var ch_out;

amqp.connect('amqp://' +process.env.RABBITMQ_USERNAME + ':' + process.env.RABBITMQ_PASSWORD +'@rabbitmq.cloud66.local', function(err, conn) {
  ch_in = conn.createChannel();
  ch_in.assertQueue('bakery.donut.order', {durable: true});
  ch_out = conn.createChannel();
  ch_out.assertQueue('bakery.sweet.done', {durable: true});
  ch_in.prefetch(1);
  console.log(process.env.HOSTNAME + ":-- [*] Waiting for donut back orders (backing time = " + secs + ")");
  ch_in.consume('bakery.donut.order', function(msg) {
    data = JSON.parse(msg.content.toString());
    console.log(process.env.HOSTNAME + ":-- [.] Start backing a " + data.flavour + " donut");
    setTimeout(function() {
      console.log(process.env.HOSTNAME + ":-- [.] Start backing a " + data.flavour + " donut done");
      ch_in.ack(msg);
      ch_out.sendToQueue('bakery.sweet.done', new Buffer(msg.content), {persistent: true});
    }, secs * 1000);
  }, {noAck: false});
});