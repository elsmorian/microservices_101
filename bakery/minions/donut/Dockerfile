FROM node:5.9.1-slim
RUN apt-get update
RUN apt-get install netcat -y


#set working dir
RUN mkdir /home/app
WORKDIR /home/app
COPY . /home/app
RUN npm install amqplib

#start the bagel minion
CMD /home/app/start_donut_minion.sh