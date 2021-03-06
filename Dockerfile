# Dockerfile for building Ansible image for Ubuntu 16.04 (Xenial), with as few additional software as possible.
#
# @see https://launchpad.net/~ansible/+archive/ubuntu/ansible
#
# Version  1.0
#

FROM vault:0.10.1 as vault


# pull base image
FROM ubuntu:16.04

MAINTAINER Emil <boolman@gmail.com> 

RUN echo "===> Adding Ansible's PPA..."  && \
    DEBIAN_FRONTEND=noninteractive  && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ansible/ansible && \
    apt-get update  && \ 
    \
    \
    echo "===> Installing Ansible..."  && \
    apt-get install -y ansible  && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    apt-get install -y python-pip              && \
    pip install --upgrade pywinrm              && \
    apt-get install -y sshpass openssh-client  && \
    \
    \
    echo "===> Removing Ansible PPA..."  && \
    rm -rf /var/lib/apt/lists/*  /etc/apt/sources.list.d/ansible.list  && \
    \
    \
    echo "===> Adding hosts for convenience..."  && \
    echo 'localhost' > /etc/ansible/hosts

COPY --from=vault /bin/vault /vault
COPY vault_ssh /vault_ssh
COPY ansible-vault-env /usr/local/bin/ansible-vault-env

RUN /bin/chmod 755 /vault && \
    /bin/chmod 755 /vault_ssh && \
    /bin/chmod 755 /usr/local/bin/ansible-vault-env

RUN sed -i 's/#remote_user.*/remote_user = ubuntu/g' /etc/ansible/ansible.cfg && \
    sed -i '/\[ssh_connection\]/a ssh_executable = \/vault_ssh\nssh_args = ""' /etc/ansible/ansible.cfg && \
    sed -i 's/#vault_password_file.*/vault_password_file = \/usr\/local\/bin\/ansible-vault-env/g' /etc/ansible/ansible.cfg

# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
