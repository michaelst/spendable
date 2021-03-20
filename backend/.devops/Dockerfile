FROM elixir:1.11-alpine AS build

ENV MIX_ENV=prod \
    LANG=C.UTF-8

WORKDIR /app

RUN apk add --update --no-cache build-base git \
  && mix local.hex --force \
  && mix local.rebar --force

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs ./config/
RUN mix do deps.get --only prod, deps.compile

COPY lib lib
COPY priv priv
RUN mix compile

COPY config/releases.exs ./config/
RUN mix release

FROM alpine:3.12 AS release

ENV LANG=C.UTF-8

RUN apk add --update --no-cache openssl ncurses-libs
RUN addgroup -S app && adduser -S app -G app 

USER app
WORKDIR /home/app

COPY --from=build --chown=app:app /app/_build/prod/rel/spendable ./
COPY --chown=app:app .devops/entrypoint.sh .
CMD ["./entrypoint.sh"]
