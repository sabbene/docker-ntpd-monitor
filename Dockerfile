FROM centos:latest

RUN yum -y update
RUN yum -y install perl

CMD  "mkdir /app" 

CMD "/app/start.sh" 
