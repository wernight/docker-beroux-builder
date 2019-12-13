FROM docker

# Install TLS certificats, and curl (always useful).
RUN apk add --no-cache ca-certificates curl zlib libgcc

RUN set -x && \
    # Install glibc on Alpine (required by docker-compose) from
    # https://github.com/sgerrand/alpine-pkg-glibc
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
    curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -Lo /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk && \
    apk add --no-cache /tmp/glibc.apk && \
    rm /tmp/glibc.apk

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib:/usr/lib

# Install docker-compose
# https://docs.docker.com/compose/install/
RUN set -x && \
    #DOCKER_COMPOSE_URL=https://github.com$(wget -q -O- https://github.com/docker/compose/releases/latest \
    #    | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' \
    #    | sed 's/^href="//' \
    #    | head -n1) && \
    DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/1.24.0/docker-compose-Linux-x86_64" && \
    wget -O /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    docker-compose version

# Install kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl
RUN set -x && \
    #KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    KUBECTL_VERSION=v1.14.0 && \
    curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl && \
    chmod a+rx /usr/local/bin/kubectl && \
    kubectl version --client

# Install envsubst (part of gettext package).
# (at least until we have https://github.com/kubernetes/kubernetes/issues/23896 )
RUN set -x && \
    apk add --no-cache gettext

# Install Helm client (better replacement to envsubst).
# https://github.com/helm/helm/releases
RUN set -x && \
    apk add --no-cache -t .deps openssl bash && \
    wget https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get && \
    chmod +x get && \
    ./get --version v2.13.1 && \
    rm get && \
    apk del --purge .deps && \
    # Verify
    helm version --client

# Sets default path
# See https://gitlab.com/gitlab-org/gitlab-runner/issues/4684
ENV PATH="${PATH:-/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin}"

# Default directory
WORKDIR /code

COPY beroux-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/sh", "-e", "/usr/local/bin/beroux-entrypoint.sh"]
