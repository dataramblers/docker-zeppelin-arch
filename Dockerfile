# Set base image
FROM base/archlinux

ENV Z_VERSION="0.8.0-SNAPSHOT" \
LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
Z_HOME="/zeppelin" \
LANG=en_US.UTF-8

WORKDIR /buildenv

RUN pacman -Syy && \
pacman -S --noconfirm -q nodejs npm git jdk8-openjdk maven bower && \
echo '{ "allow_root": true }' > /root/.bowerrc && \
git clone https://github.com/dataramblers/zeppelin.git && \
cd ./zeppelin && \
./dev/change_scala_version.sh 2.11 && \
mvn clean package \
-DskipTests \
-Dbuild-distr \
-Dflink.version=1.3.2 \
-Dlucene.version=6.6.1 \
-Pspark-2.1 \
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
!scio" && \
chmod +x bin/zeppelin.sh && \
find bin -type f -name "*.cmd" -exec rm {} \; && \
rm -r alluxio \
angular \
beam \
bigquery \
cassandra \
dev \
docs \
elasticsearch \
file \
geode \
groovy \
hbase \
helium-dev \
ignite \
jdbc \
kylin \
lens \
LICENSE \
licenses \
livy \
NOTICE \
pig \
pom.xml \
README.md \
Roadmap.md \
scalding \
scio \
scripts \
SECURITY-README.md \
STYLE.md \
testing _tools \
travis_check.py \
zeppelin-examples \
.git* && \
rm -r /root/.m2 && \
pacman -Rsc --noconfirm nodejs npm maven bower && \
pacman -Sc --noconfirm

COPY . /buildenv

FROM openjdk:8-alpine

WORKDIR /zeppelin/
COPY --from=0 /buildenv/zeppelin .
RUN apk add --no-cache --update bash python && \
rm -r /var/cache/apk/*

ENV PATH=$PATH:/zeppelin/bin

VOLUME /zeppelin/notebook
EXPOSE 8080

ENTRYPOINT ["/bin/bash", "zeppelin.sh"]
