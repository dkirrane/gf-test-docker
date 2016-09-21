#
# Dockerfile for Maven & Git
#
# docker-compose build mvngit
# docker run -it --name="mvngit" dockercelite_mvngit
# docker rm -f mvngit
#
FROM ubuntu:14.04.2

MAINTAINER Desmond Kirrane <dkirrane at avaya.com>

ENV REFRESHED_AT 2016-SPET-21

######################
# Install
######################
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq wget curl supervisor unzip git \
    && apt-get clean

######################
# Install Java 7
######################
RUN apt-get install software-properties-common -y && add-apt-repository ppa:webupd8team/java -y
RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq oracle-java7-installer
RUN update-java-alternatives -s java-7-oracle
ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

######################
# Install Maven
######################
ARG MAVEN_VERSION

RUN curl -sSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-${MAVEN_VERSION} /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV M2_HOME /usr/share/maven
ENV MAVEN_OPTS -Xms1024m -Xmx1024m -XX:PermSize=1024m
ENV MAVEN_REPO /root/.m2/repository

######################
# Clone test Repo
######################
WORKDIR /opt
RUN git clone https://github.com/dkirrane/gf-test.git

WORKDIR /opt/gf-test/my-proj
RUN mvn dependency:go-offline
RUN mvn dependency:resolve
RUN mvn dependency:resolve-plugins

######################
# Gitflow Commands
######################
ARG GITFLOW_VERSION

# Clean up and previous runs for this repo
RUN clear-git-history.sh

# Init
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:init

# Feature
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:feature-start
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:feature-finish

# Release
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:release-start
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:release-finish

# Hotfix
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:hotfix-start
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:hotfix-finish

# Support
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:support-start
RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:support-tag

CMD ["bash"]