FROM docker

# Install TLS certificats, and curl (always useful).
RUN apk add --no-cache ca-certificates curl

RUN set -x && \
    # Install glibc on Alpine (required by docker-compose) from
    # https://github.com/sgerrand/alpine-pkg-glibc
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
    GLIBC_VERSION='2.26-r0' && \
    curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    curl -Lo /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk && \
    curl -Lo /tmp/glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk && \
    apk add --no-cache /tmp/glibc.apk /tmp/glibc-bin.apk && \
    rm /tmp/glibc.apk /tmp/glibc-bin.apk && \
    \
    # Install docker-compose
    # https://docs.docker.com/compose/install/
    DOCKER_COMPOSE_URL=https://github.com$(curl -L https://github.com/docker/compose/releases/latest \
        | grep -Eo 'href="[^"]+docker-compose-Linux-x86_64' \
        | sed 's/^href="//' \
        | head -n1) && \
    curl -Lo /usr/local/bin/docker-compose $DOCKER_COMPOSE_URL && \
    chmod a+rx /usr/local/bin/docker-compose && \
    docker-compose version && \
    \
    # Install kubectl
    # https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl
    curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod a+rx /usr/local/bin/kubectl && \
    \
    # Install envsubst (part of gettext package).
    # (at least until we have https://github.com/kubernetes/kubernetes/issues/23896 )
    apk add --no-cache gettext && \
    \
    # Clean-up
    apk del .deps && \
    \
    # Verify
    kubectl version --client

# Default directory
WORKDIR /code

COPY beroux-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["beroux-entrypoint.sh"]
