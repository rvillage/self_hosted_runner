#-------------------------------------------------------------------------------
# global args
#-------------------------------------------------------------------------------

ARG ubuntu_version=20.04

#-------------------------------------------------------------------------------
# for main build
#-------------------------------------------------------------------------------

FROM ubuntu:${ubuntu_version}

ARG runner_version=2.277.1

ENV DEBIAN_FRONTEND=noninteractive
ENV ImageOS=ubuntu20
ENV TZ=Asia/Tokyo

RUN apt-get update \
    && apt-get install -y \
      apt-transport-https \
      ca-certificates \
      curl \
      gzip \
      jq \
      software-properties-common \
      sudo \
      unzip \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    && apt update && apt install -y docker-ce docker-ce-cli containerd.io \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key C99B11DEB97541F0 \
    && apt-add-repository https://cli.github.com/packages \
    && apt update && apt install gh \
    && cd /tmp \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && apt-get -y clean \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN useradd -m runner \
    && echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && usermod -aG docker runner \
    && mkdir -p /home/runner/actions-runner \
    && cd /home/runner/actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${runner_version}/actions-runner-linux-x64-${runner_version}.tar.gz \
    && tar xzf actions-runner-linux-x64-${runner_version}.tar.gz \
    && chown -R runner /home/runner \
    && rm actions-runner-linux-x64-${runner_version}.tar.gz

RUN /home/runner/actions-runner/bin/installdependencies.sh
RUN mkdir -p /opt/hostedtoolcache \
    && chown -R runner /opt/hostedtoolcache

COPY --chown=runner:runner start-runner.sh /home/runner/

WORKDIR /home/runner
USER runner

CMD ["./start-runner.sh"]
