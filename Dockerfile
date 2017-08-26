# Set base image
FROM base/archlinux

RUN pacman -Syy
RUN pacman -S --noconfirm -q nodejs npm git jdk8-openjdk maven bower r
RUN pacman -Sc

# Ensuring that bower can be run by root (required in the installation step of Zeppelin
RUN echo '{ "allow_root": true }' > /root/.bowerrc

ENV Z_VERSION="0.8.0-SNAPSHOT"
ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
Z_HOME="/zeppelin" \
LANG=en_US.UTF-8 \
LC_ALL=en_US.UTF-8

# Install Zeppelin
RUN git clone https://github.com/apache/zeppelin.git
WORKDIR ./zeppelin
RUN mvn clean package \
-DskipTests \
-Dbuild-distr \
-Dflink.version=1.3.2 \
-Pspark-2.1 \
-Psparkr \
-Pyarn \
-Phadoop-2.7 \
-Pscala-2.11 \
--projects \
"!groovy,\
!angular,\
!shell,\
!livy,\
!hbase,\
!pig,\
!jdbc,\
!file,\
!ignite,\
!kylin,\
!lens,\
!cassandra,\
!elasticsearch,\
!bigquery,\
!alluxio,\
!scio"

# Tidying up
RUN find bin -type f -name "*.cmd" -exec rm {} \;
RUN rm -r alluxio angular beam bigquery cassandra dev docs elasticsearch file geode groovy hbase helium-dev ignite jdbc kylin lens LICENSE licenses livy NOTICE pig pom.xml README.md Roadmap.md scalding scio scripts SECURITY-README.md STYLE.md testing _tools travis_check.py zeppelin-examples .git*

ADD * /zeppelin/
VOLUME /zeppelin/notebook

EXPOSE 8080
WORKDIR /zeppelin
RUN chmod +x bin/zeppelin.sh
ENTRYPOINT ["/bin/bash", "bin/zeppelin.sh"]
