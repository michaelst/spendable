FROM elixir:1.9.1-alpine AS builder
WORKDIR /workspace
COPY . /workspace
ENV MIX_ENV=prod
RUN mix do local.hex --force, local.rebar --force, deps.get --only prod, compile, release

FROM alpine:3.9
WORKDIR /opt/app
RUN apk update && apk add --no-cache openssl-dev
COPY --from=builder /workspace/_build/prod/rel/budget .
CMD ./bin/budget start
