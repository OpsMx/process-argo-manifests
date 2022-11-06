FROM ubuntu:jammy
LABEL maintainer="srinivas@opsmx.io"

# Fix 'ordinal not in range' error.
ENV LC_CTYPE en_US.UTF-8
ENV LANG en_US.UTF-8
# Install dependencies.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       locales \
       sshpass \
       ssh \
       git \
       wget \
       rsyslog \
       curl \
    && rm -Rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt-get clean
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

ARG VERSION=v4.9.6
ARG BINARY=yq_linux_386
RUN wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq \ 
    && chmod +x /usr/bin/yq

WORKDIR /tmp
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash 
RUN cp kustomize /usr/bin/kustomize
RUN chmod +x /usr/bin/kustomize
RUN locale-gen en_US.UTF-8
RUN useradd -m opsmx
USER opsmx
ENV PATH=$PATH:/home/opsmx/.local/bin
