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
RUN git clone https://github.com/xrowgmbh/ansible-role-ansible.git /ansible-role-ansible
ADD test.yml /ansible-role-ansible/test.yml
ADD requirements.yml /ansible-role-ansible/requirements.yml
RUN ansible-galaxy install -r -p /ansible-role-ansible/roles/ requirements.yml 
RUN ansible-playbook /ansible-role-ansible/test.yml

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]
