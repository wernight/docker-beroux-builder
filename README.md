# Supported tags and respective `Dockerfile` links

  * `latest` latest stable release
  * `1`, `1.8`, `1.8.0` (or similar) are like `latest` but for a specific version of Kubernetes (kubectl).

Beroux-Builder [![](https://images.microbadger.com/badges/image/wernight/beroux-builder.svg)](http://microbadger.com/images/wernight/beroux-builder "Get your own image badge on microbadger.com")
==============

Bundle with almost minimal set of utilities to build Docker images and deploy them on Kubernetes:

  * `docker`
  * `docker-compose`
  * `kubectl`
  * `envsubst`

Also automatically creates a `kubectl` context using the service account
if it detects there is one.


# Usage

You should provide a Docker daemon either:
  - Link a `docker` host pointing to `docker:dind`, or
  - Mount host Docker socket `/var/run/docker.sock`, or
  - Set `DOCKER_HOST` to where this container can reach a Docker daemon.

## Example for GitLab CI

For example you can run GitLab CI with a `.gitlab-ci.yml` like:

    build:
      stage: build
      image: wernight/beroux-builder
      services:
        - docker:dind
      before_script:
        - docker info
        - docker-compose version
        - docker login -u _json_key -p "$DOCKER_REGISTRY_TOKEN" https://eu.gcr.io
        - kubectl cluster-info
      script:
        - docker-compose build --pull
        - docker push my-repo/my-image
        - cat kubernetes.yml | envsubst | kubectl apply -f -

For this to work, you need:

   - `gitlab-ci-multi-runner` set up in *Docker* mode with:
       - Environment variable `DOCKER_REGISTRY_TOKEN` set to access your Docker Registry (if private).
       - Kubernetes service account mounted (`/var/run/secrets/kubernetes.io/serviceaccount/`).
