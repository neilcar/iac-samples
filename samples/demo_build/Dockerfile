FROM alpine:3.8
 
# Modified from http://ruleoftech.com/2017/dockerizing-all-the-things-running-ansible-inside-docker-container

ENV ANSIBLE_VERSION 2.7.0
 
ENV BUILD_PACKAGES \
  bash \
  curl \
  tar \
  openssh-client \
  sshpass \
  git \
  python \
  py-boto \
  py-dateutil \
  py-httplib2 \
  py-jinja2 \
  py-paramiko \
  py-pip \
  py-yaml \
  ca-certificates
 
# If installing ansible@testing
#RUN \
#	echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> #/etc/apk/repositories
 
RUN set -x && \
    \
    echo "==> Adding build-dependencies..."  && \
    apk --update add --virtual build-dependencies \
      gcc \
      musl-dev \
      libffi-dev \
      openssl-dev \
      python-dev \
      tar && \
    \
    echo "==> Upgrading apk and system..."  && \
    apk update && apk upgrade && \
    \
    echo "==> Adding Python runtime..."  && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    pip install --upgrade pip && \
    pip install jmespath python-keyczar docker-py apache-libcloud google-api-python-client google-auth google-auth-httplib2 && \
    \
    echo "==> Installing Ansible..."  && \
    pip install ansible==${ANSIBLE_VERSION} && \
    \
    echo "==> Cleaning up..."  && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    \
    echo "==> Adding hosts for convenience..."  && \
    mkdir -p /etc/ansible /ansible && \
    echo "[local]" >> /etc/ansible/hosts && \
    echo "localhost" >> /etc/ansible/hosts && \
    wget https://files.pythonhosted.org/packages/source/m/mitogen/mitogen-0.2.5.tar.gz && \
    tar -xvzf mitogen-0.2.5.tar.gz -C /ansible
 
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /ansible/playbooks/roles
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library
ENV ANSIBLE_STRATEGY_PLUGINS /ansible/mitogen-0.2.5/ansible_mitogen/plugins/strategy
ENV ANSIBLE_STRATEGY mitogen_linear
ENV ANSIBLE_STDOUT_CALLBACK yaml
ENV ANSIBLE_LOAD_CALLBACK_PLUGINS True


ADD playbooks/roles/ /ansible/playbooks/roles/
ADD playbooks/*.yml /ansible/playbooks/
ADD playbooks/lookup_plugins/ /ansible/playbooks/lookup_plugins/
ADD playbooks/templates/ /ansible/playbooks/templates/

WORKDIR /ansible/playbooks
 
ENTRYPOINT ["ansible-playbook"]
CMD ["-i","inventory.yml","my_lab.yml","-T 400"]
