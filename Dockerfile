FROM docker-release.otlabs.fr/docker-release-local/infra/docker-centos_i386-gcc:jdk8_131.11_V2

LABEL author="Tomasz Malinowski <t.malinowski@oberthur.com>"
LABEL type="docker-centos_i386-rpmbuilder"

ENV SWARM_VERSION 2.2
ENV KERNEL_VERSION 2.6.32-696.3.2.el6.i686

COPY rpmmacros /root/.rpmmacros
COPY fakeuname.sh /usr/local/sbin/fakeuname.sh
COPY fakebash.sh /usr/local/sbin/fakebash.sh

RUN curl -o /opt/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar http://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}-jar-with-dependencies.jar \
  && echo -e '#!/bin/bash\n\nexec java -jar /opt/swarm-client-$SWARM_VERSION-jar-with-dependencies.jar -disableClientsUniqueId -username $JENKINS_USERNAME -password $JENKINS_PASSWORD -mode ${JENKINS_MODE:-exclusive} -name $JENKINS_SLAVE_NAME -executors ${JENKINS_EXEC_NR:-1} -master ${JENKINS_URL:-127.0.0.1} -fsroot $JENKINS_FS_ROOT -labels "${JENKINS_LABELS:-swarm}"' > /usr/bin/swarm_slave.sh \
  && chmod +x /usr/bin/swarm_slave.sh \

  && yum -y update \
  && yum install -y yum-plugin-ovl python-setuptools python-devel kernel-$KERNEL_VERSION kernel-headers-$KERNEL_VERSION kernel-devel-$KERNEL_VERSION rpmdevtools \

  && easy_install supervisor \
  && mkdir -p /etc/supervisord/conf.d \
  && echo_supervisord_conf > /etc/supervisord/supervisord.conf \
  && echo -e "\n[include]\nfiles = /etc/supervisord/conf.d/*.ini" >>  /etc/supervisord/supervisord.conf \
  && echo -e "[program:swarm_slave]\ncommand=/usr/bin/swarm_slave.sh\nuser=root" > /etc/supervisord/conf.d/supervisor.ini \

  && rpmdev-setuptree \
  && chmod 700 /usr/local/sbin/fakeuname.sh \
  && ln -s /usr/local/sbin/fakeuname.sh /usr/local/sbin/uname \
  
  && chmod 700 /usr/local/sbin/fakebash.sh \
  && ln -s /usr/local/sbin/fakebash.sh /usr/local/sbin/bash \

# clean all cache to clean space
  && rm -rf /var/cache/yum/* \
  && yum clean all

ENTRYPOINT [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisord/supervisord.conf" ]
