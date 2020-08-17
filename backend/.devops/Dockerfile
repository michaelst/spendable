FROM elixir:1.10-alpine AS build

RUN apk add --update build-base

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV=prod \
    LANG=C.UTF-8

ARG DB_PASSWORD
ARG GUARDIAN_SECRET
ARG PLAID_CLIENT_ID
ARG PLAID_PUBLIC_KEY
ARG PLAID_SECRET_KEY
ARG SECRET_KEY_BASE
ARG SENTRY_DSN

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs ./config/
RUN mix deps.get
RUN mix deps.compile

COPY lib lib
COPY priv priv
RUN mix compile
RUN mix release

FROM alpine:3.12

ENV LANG=C.UTF-8

RUN apk add --update bash openssl ncurses-libs

RUN mkdir /app
WORKDIR /app

COPY --from=build /app/_build/prod/rel/spendable ./
COPY .devops/entrypoint.sh .
CMD ["./entrypoint.sh"]