FROM centos/systemd
LABEL maintainer="Björn Dieding"
ENV container=docker

# Install Ansible and other requirements.
RUN yum makecache fast \
 && yum -y install deltarpm epel-release initscripts \
 && yum -y update \
 && yum -y install \
      ansible \
      sudo \
      which \
      git \
&& yum clean all

# Disable requiretty.
RUN sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers

# Install Ansible inventory file.
RUN echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
ADD test.yml /root/.ansible/test.yml
ADD requirements.yml /root/.ansible/requirements.yml
RUN ansible-galaxy install -r /root/.ansible/requirements.yml

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init && ansible-playbook /root/.ansible/test.yml"]
