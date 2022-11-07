FROM ubuntu:18.04

RUN apt-get update && apt-get install -y mtr-tiny traceroute netcat dnsutils curl
COPY run.sh /run.sh
RUN chmod 777 /run.sh
ENTRYPOINT ["/run.sh"]