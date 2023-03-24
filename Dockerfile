FROM docker

# https://dl.k8s.io/release/stable.txt
ARG KUBECTL_VERSION=v1.26.3
# https://github.com/helm/helm/releases
ARG HELM_VERSION=v3.11.2

# Install TLS certificats, and curl + bash (always useful).
RUN apk add --no-cache ca-certificates curl zlib libgcc bash

# Required for docker-compose to find zlib.
ENV LD_LIBRARY_PATH=/lib:/usr/lib

# Install kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-via-curl
RUN set -x && \
    curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
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
    ./get --version $HELM_VERSION && \
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
