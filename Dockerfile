#
# Dockerfile for Maven & Git
#
# docker-compose build mvngit
# docker run -it --name="mvngit" dockercelite_mvngit
# docker rm -f mvngit
#
FROM maven:3.3.9-jdk-7
# FROM maven:3.0.5-jdk-7

MAINTAINER Desmond Kirrane <dkirrane at avaya.com>

ENV REFRESHED_AT 2016-SPET-22

######################
# Install
######################
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq git \
    && apt-get clean

# ######################
# # Install Java 7
# ######################
# RUN apt-get install software-properties-common -y && add-apt-repository ppa:webupd8team/java -y
# RUN echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq oracle-java7-installer
# RUN update-java-alternatives -s java-7-oracle
# ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# ######################
# # Install Maven
# ######################
# ARG MAVEN_VERSION

# RUN curl --insecure https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar xzf - -C /usr/share \
#   && mv /usr/share/apache-maven-${MAVEN_VERSION} /usr/share/maven \
#   && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# ENV M2_HOME /usr/share/maven
# ENV MAVEN_OPTS -Xms1024m -Xmx1024m -XX:PermSize=1024m
# ENV MAVEN_REPO /root/.m2/repository

######################
# Clone test Repo
######################
ENV CLONED_AT 2016-SPET-22
WORKDIR /opt
RUN git clone https://github.com/dkirrane/gf-test.git
ENV PROJ_DIR=/opt/gf-test/my-proj

WORKDIR ${PROJ_DIR}
# RUN mvn dependency:go-offline
# RUN mvn dependency:resolve
# RUN mvn dependency:resolve-plugins

# GitHub username password
ENV GITHUB_USERNAME ${GITHUB_USERNAME}
ENV GITHUB_PASSWORD ${GITHUB_PASSWORD}
RUN echo "machine github.com login ${GITHUB_USERNAME} password ${GITHUB_PASSWORD}" > ~/.netrc
RUN git config --global user.email "${GITHUB_USERNAME}"
RUN git config --global user.name "${GITHUB_USERNAME}"

# Clean up and previous runs for this repo
# RUN chmod -Rf 777 *
# RUN ${PROJ_DIR}/clear-git-history.sh
# WORKDIR ${PROJ_DIR}

######################
# Gitflow Commands
######################
ARG GITFLOW_VERSION
ENV GITFLOW_VERSION=${GITFLOW_VERSION}
RUN echo "GITFLOW_VERSION: ${GITFLOW_VERSION}"

ARG MAVEN_VERSION
RUN echo "MAVEN_VERSION: ${MAVEN_VERSION}"
RUN mvn --version

##
# Java - keytool import CA cert
##
ADD certs/ca.pem /tmp/
RUN ${JAVA_HOME}/bin/keytool -import -noprompt -file "/tmp/ca.pem" -alias ZscalerAlias -keystore ${JAVA_HOME}/jre/lib/security/cacerts -storepass changeit
ENV MAVEN_OPTS=-Xmx1024m -Djavax.net.ssl.trustStore="${JAVA_HOME}/jre/lib/security/cacerts" -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.keyStore="${JAVA_HOME}/jre/lib/security/cacerts" -Djavax.net.ssl.keyStorePassword=changeit

# Download
RUN mvn -U com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:download

# Init
# RUN mvn -U com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:init

# # # Feature
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:feature-start
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:feature-finish

# # Release
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:release-start
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:release-finish

# # Hotfix
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:hotfix-start
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:hotfix-finish

# # Support
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:support-start
# RUN mvn com.dkirrane.maven.plugins:ggitflow-maven-plugin:${GITFLOW_VERSION}:support-tag

CMD ["sleep", "30000000"]
# CMD ["bash"]