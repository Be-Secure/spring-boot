#!/bin/bash
set -ex

###########################################################
# UTILS
###########################################################

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install --no-install-recommends -y tzdata ca-certificates net-tools libxml2-utils git curl libudev1 libxml2-utils iptables iproute2 jq
ln -fs /usr/share/zoneinfo/UTC /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata
rm -rf /var/lib/apt/lists/*

curl https://raw.githubusercontent.com/spring-io/concourse-java-scripts/v0.0.4/concourse-java.sh > /opt/concourse-java.sh


###########################################################
# JAVA
###########################################################
JDK_URL=$( ./get-jdk-url.sh $1 )

mkdir -p /opt/openjdk
cd /opt/openjdk
curl -L ${JDK_URL} | tar zx --strip-components=1
test -f /opt/openjdk/bin/java
test -f /opt/openjdk/bin/javac

if [[ $# -eq 2 ]]; then
	cd /
	TOOLCHAIN_JDK_URL=$( ./get-jdk-url.sh $2 )

	mkdir -p /opt/openjdk-toolchain
	cd /opt/openjdk-toolchain
	curl -L ${TOOLCHAIN_JDK_URL} | tar zx --strip-components=1
	test -f /opt/openjdk-toolchain/bin/java
	test -f /opt/openjdk-toolchain/bin/javac
fi


###########################################################
# DOCKER
###########################################################
cd /
DOCKER_URL=$( ./get-docker-url.sh )
curl -L ${DOCKER_URL} | tar zx
mv /docker/* /bin/
chmod +x /bin/docker*

export ENTRYKIT_VERSION=0.4.0
curl -L https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz | tar zx
chmod +x entrykit && \
mv entrykit /bin/entrykit && \
entrykit --symlink


###########################################################
# DOCKER COMPOSE
###########################################################
mkdir -p /usr/local/lib/docker/cli-plugins
DOCKER_COMPOSE_URL=$( ./get-docker-compose-url.sh )
curl -L ${DOCKER_COMPOSE_URL} -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
