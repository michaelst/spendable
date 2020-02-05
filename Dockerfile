FROM elixir:1.10-alpine AS build

RUN apk add --update build-base

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod
ARG DB_PASSWORD
ARG GUARDIAN_SECRET
ARG PLAID_CLIENT_ID
ARG PLAID_PUBLIC_KEY
ARG PLAID_SECRET_KEY
ARG SECRET_KEY_BASE

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

COPY lib lib
COPY priv/static priv/static
RUN mix compile
RUN mix release

FROM alpine:3.9
RUN apk add --update bash openssl ncurses-libs

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/spendable ./
CMD ./bin/spendable start
