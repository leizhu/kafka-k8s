FROM ubuntu:14.04
MAINTAINER Lei Zhu <lei.zhu.1017@gmail.com>

COPY sources.list /etc/apt/sources.list

RUN apt-get update && apt-get install -y openjdk-7-jdk

# The Scala 2.11 build is currently recommended by the project.
ENV KAFKA_VERSION=0.10.2.0 KAFKA_SCALA_VERSION=2.11 JMX_PORT=7203
ENV KAFKA_RELEASE_ARCHIVE kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN mkdir /kafka /data 
RUN chmod -R 777 /kafka /data 

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates

# Download Kafka binary distribution
COPY ${KAFKA_RELEASE_ARCHIVE} /tmp/
COPY ${KAFKA_RELEASE_ARCHIVE}.md5 /tmp/

WORKDIR /tmp

# Check artifact digest integrity
RUN echo VERIFY CHECKSUM: && \
  gpg --print-md MD5 ${KAFKA_RELEASE_ARCHIVE} 2>/dev/null && \
  cat ${KAFKA_RELEASE_ARCHIVE}.md5

# Install Kafka to /kafka
RUN tar -zx -C /kafka --strip-components=1 -f ${KAFKA_RELEASE_ARCHIVE} && \
  rm -rf kafka_*

ADD config /kafka/config
ADD start.sh /start.sh

# Set up a user to run Kafka
#RUN groupadd kafka && \
#  useradd -d /kafka -g kafka -s /bin/false kafka && \
#  chown -R kafka:kafka /kafka /data 
#USER kafka
ENV PATH /kafka/bin:$PATH
WORKDIR /kafka

# broker, jmx
EXPOSE 9092 ${JMX_PORT}
VOLUME [ "/data" ]

CMD ["/start.sh"]

