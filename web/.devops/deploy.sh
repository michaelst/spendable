COMMIT_SHA=$(git rev-parse HEAD)
docker build -t ghcr.io/michaelst/spendable-web:$COMMIT_SHA .
docker push ghcr.io/michaelst/spendable-web:$COMMIT_SHA

helm upgrade --install spendable-web ../../server-config/helm-app \
  -f .devops/helm/values.yaml \
  --set image.repository=ghcr.io/michaelst/spendable-web \
  --set image.tag=$COMMIT_SHA \
  --atomic \
  --debug \
  -n frontend