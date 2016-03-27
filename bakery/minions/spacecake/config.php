<?php

require_once __DIR__ . '/vendor/autoload.php';

define('HOST', 'rabbitmq.cloud66.local');
define('PORT', 5672);
define('USER', $_ENV['RABBITMQ_USERNAME']);
define('PASS', $_ENV['RABBITMQ_PASSWORD']);
define('VHOST', '/');

//If this is enabled you can see AMQP output on the CLI
define('AMQP_DEBUG', false);