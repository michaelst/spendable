COMMIT_SHA=$(git rev-parse HEAD)
docker build -t ghcr.io/michaelst/spendable-api:$COMMIT_SHA .
docker push ghcr.io/michaelst/spendable-api:$COMMIT_SHA

helm upgrade --install spendable-api ../../server-config/helm-app \
  -f .devops/helm/values.yaml \
  --set image.repository=ghcr.io/michaelst/spendable-api \
  --set image.tag=$COMMIT_SHA \
  --atomic \
  --debug \
  -n backend