FROM tomcat:7
MAINTAINER Neil Carpenter <neil@twistlock.com>
RUN apt-get update
RUN apt-get -y install curl git nmap dnsutils
RUN set -ex \
	&& rm -rf /usr/local/tomcat/webapps/* \
	&& chmod a+x /usr/local/tomcat/bin/*.sh
RUN curl -o /opt/jackson-databind-2.7.8.jar http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.7.8/jackson-databind-2.7.8.jar
RUN curl -o /opt/jackson-databind-2.6.7.1.jar http://central.maven.org/maven2/com/fasterxml/jackson/core/jackson-databind/2.6.7.1/jackson-databind-2.6.7.1.jar
EXPOSE 8080