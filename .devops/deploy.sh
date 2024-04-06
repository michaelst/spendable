#!/bin/sh

set -e

cd "`dirname $0`"/..

export DOCKER_HOST="ssh://michael@arctic.local"
COMMIT_SHA=$(git rev-parse HEAD)

docker buildx build -t ghcr.io/michaelst/spendable:$COMMIT_SHA . --push

helm upgrade --install spendable oci://ghcr.io/michaelst/helm/cloud-57 \
  -f .devops/values.yaml \
  --set image.repository=ghcr.io/michaelst/spendable \
  --set image.tag=$COMMIT_SHA \
  --version 1.0.6 \
  --atomic \
  -n spendable