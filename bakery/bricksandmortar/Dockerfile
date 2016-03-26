FROM ruby:2.1.8

RUN apt-get update
RUN apt-get install nodejs -y
RUN apt-get install nginx -y

#set working dir for caching
WORKDIR /tmp

#cache bundle install
ADD middleman/Gemfile /tmp/Gemfile
ADD middleman/Gemfile.lock /tmp/Gemfile.lock

RUN bundle install

RUN rm -f /etc/service/nginx/down
ADD nginx/default.conf /etc/nginx/sites-available/default
ADD nginx/nginx.conf /etc/nginx/nginx.conf

#set working dir
WORKDIR /home/app
COPY middleman /home/app


#cache buster
ENV CACHEBUSTER 143431671722
#ARG COUNTER_ADDRESS
#ARG COUNTER_PORT
ENV COUNTER_ADDRESS ${COUNTER_ADDRESS}
ENV COUNTER_PORT ${COUNTER_PORT}
RUN env

#start middleman as development server
RUN bundle exec middleman build --verbose
CMD nginx
