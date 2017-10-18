# based on debian:7
# with oracle-jdk8 sbt redis mongo net-tools procps installed

FROM debian:7

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list \
    && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | tee /etc/apt/sources.list.d/mongodb-org-3.2.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 99E82A75642AC823 \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 \
    && echo "deb http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list \
    && echo "deb-src http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list \
    && apt-get install -f && rm -rf /var/lib/apt/lists/* \
    && apt-get update -y && apt-get install -y wget \
    && wget http://www.dotdeb.org/dotdeb.gpg \
    && apt-key add dotdeb.gpg \
    && echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections \
    && apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default unzip procps net-tools mongodb-org redis-server redis-tools

# install sbt
RUN wget -c 'http://repo1.maven.org/maven2/org/scala-sbt/sbt-launch/1.0.0-M4/sbt-launch.jar' \
    && mv sbt-launch.jar /var \
    && echo '#!/bin/bash' > /usr/bin/sbt \
    && echo 'java -Xms512M -Xmx1536M -Xss1M -XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M -jar /var/sbt-launch.jar "$@"' >> /usr/bin/sbt \
    && chmod u+x /usr/bin/sbt

# copy ivy2 cache lib to docker
COPY ./cache.zip /root
RUN cd /root && unzip cache.zip && mkdir -p /root/.ivy2 && mv /root/cache /root/.ivy2

# config timezone
RUN echo "Asia/Harbin" > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
