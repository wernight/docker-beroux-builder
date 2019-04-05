FROM docker

# Install TLS certificats, and curl (always useful).
RUN apk add --no-cache ca-certificates curl zlib

RUN set -x && \
    # Install glibc on Alpine (required by docker-compose) from
    # https://github.com/sgerrand/alpine-pkg-glibc
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
    curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    curl -Lo /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk && \
    apk add --no-cache /tmp/glibc.apk && \
    rm /tmp/glibc.apk

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib

RUN set -x && \
    # Install docker-compose
    # https://docs.docker.com/compose/install/
    DOCKER_COMPOSE_URL=https://github.com$(wget -q -O- https://github.com/docker/compose/releases/latest \
        | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' \
        | sed 's/^href="//' \
        | head -n1) && \
    wget -O /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    docker-compose version

RUN set -x && \
    # Install kubectl
    # https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl
    curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod a+rx /usr/local/bin/kubectl && \
    \
    # Install envsubst (part of gettext package).
    # (at least until we have https://github.com/kubernetes/kubernetes/issues/23896 )
    apk add --no-cache gettext && \
    \
    # Install Helm client (better replacement to envsubst).
    apk add --no-cache -t .deps openssl && \
    curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sh - && \
    apk del --purge .deps && \
    \
    # Verify
    kubectl version --client && \
    helm version --client

# Default directory
WORKDIR /code

COPY beroux-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["beroux-entrypoint.sh"]
