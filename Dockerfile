# based on debian:7
# with oracle-jdk8 sbt redis mongo net-tools procps installed

FROM debian:7
MAINTAINER Apollos

# install oracle-jdk8
RUN mkdir -p /home/java
ADD ./jdk-8u151-linux-x64.tar.gz /home/java/
ENV JAVA_VERSION="1.8"
ENV JAVA_HOME=/home/java/jdk1.8.0_151
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin:$PATH

# copy ivy2 cache lib and sbt-launch.jar to docker
COPY ./sbt-launch.jar /var
COPY ./cache.zip /root

# install sbt redis mongo unzip net-tools procps
# config timezone
RUN echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list \
    && echo "deb http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list \
    && echo "deb-src http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 99E82A75642AC823 \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
    && apt-get install -f && rm -rf /var/lib/apt/lists/* \
    && apt-get update -y && apt-get install -y wget \
    && wget http://www.dotdeb.org/dotdeb.gpg \
    && apt-key add dotdeb.gpg \
    && apt-get update -y \
    && apt-get install -y --force-yes unzip procps net-tools mongodb-org redis-server redis-tools locales \
    && echo '#!/bin/bash' > /usr/bin/sbt \
    && echo 'java -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -jar /var/sbt-launch.jar "$@"' >> /usr/bin/sbt \
    && chmod u+x /usr/bin/sbt \
    && cd /root && unzip cache.zip && mkdir -p /root/.ivy2 && mv /root/cache /root/.ivy2 \
    && echo "Asia/Harbin" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata \
    && rm /root/cache.zip

ENV LANG en_US.UTF-8
