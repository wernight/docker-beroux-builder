#!/bin/sh
set -e

# Auto-use Kubernetes service account:
if [ -f /var/run/secrets/kubernetes.io/serviceaccount/token ]; then
    kubectl config set-cluster default --server=https://kubernetes --certificate-authority=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
    kubectl config set-credentials service-account --token="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"
    kubectl config set-context default --cluster=default --user=service-account
    kubectl config use-context default
fi

exec docker-entrypoint.sh "$@"
