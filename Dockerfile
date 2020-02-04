FROM elixir:1.10-alpine AS builder

WORKDIR /workspace
COPY . /workspace

ENV MIX_ENV=prod
ARG DB_PASSWORD
ARG GUARDIAN_SECRET
ARG PLAID_CLIENT_ID
ARG PLAID_PUBLIC_KEY
ARG PLAID_SECRET_KEY
ARG SECRET_KEY_BASE

RUN apk update && apk upgrade --no-cache && apk add --no-cache build-base
RUN mix do local.hex --force, local.rebar --force, deps.get --only prod, compile, release

FROM alpine:3.9
WORKDIR /opt/app
RUN apk update && apk add --no-cache openssl-dev ncurses-libs
COPY --from=builder /workspace/_build/prod/rel/spendable .
CMD ./bin/spendable start
