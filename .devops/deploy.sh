COMMIT_SHA=$(git rev-parse HEAD)
docker build -t ghcr.io/michaelst/spendable:$COMMIT_SHA .
docker push ghcr.io/michaelst/spendable:$COMMIT_SHA

helm upgrade --install spendable ../../server-config/helm-app \
  -f .devops/values.yaml \
  --set image.repository=ghcr.io/michaelst/spendable \
  --set image.tag=$COMMIT_SHA \
  --atomic \
  --debug \
  -n spendable