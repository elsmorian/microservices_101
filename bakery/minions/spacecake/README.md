to download all the PHP libraries

$docker run --rm -v ${PWD}:/data imega/composer:2.0.0 install --no-dev --ignore-platform-reqs --no-interaction
