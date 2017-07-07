FROM ubuntu:14.04
MAINTAINER Lei Zhu <lei.zhu.1017@gmail.com>

COPY sources.list /etc/apt/sources.list

RUN apt-get update && \
apt-get install --no-install-recommends -y curl openjdk-7-jre-headless && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kafka-monitor/db

WORKDIR /opt/kafka-monitor

COPY KafkaOffsetMonitor-assembly-0.2.1.jar /opt/kafka-monitor/

VOLUME ["/opt/kafka-monitor/db"]

COPY start.sh /start.sh

EXPOSE 8080

CMD ["/start.sh"]
