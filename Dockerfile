FROM centos/systemd
LABEL maintainer="Björn Dieding"
ENV container=docker

ENV PATH="/opt/rh/rh-python36/root/usr/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Install Ansible and other requirements.
RUN yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      ansible \
      sudo \
      which \
      git \
      python-pip \
 && yum clean all

# Disable requiretty.
# Install Ansible inventory file.
ADD install install

RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers &&\
    echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts &&\
    ansible-galaxy install -r install/requirements.yml &&\
    ansible-playbook install/test.yml

VOLUME ["/sys/fs/cgroup"]

CMD ["/usr/sbin/init"]
