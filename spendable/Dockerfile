FROM elixir:1.15-slim AS build

ENV MIX_ENV=prod \
    LANG=C.UTF-8

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential software-properties-common git \
  && rm -rf /var/lib/apt/lists/* \
  && mix local.hex --force \
  && mix local.rebar --force

WORKDIR /app

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/runtime.exs ./config/

COPY lib lib
COPY priv priv
COPY rel rel

RUN --mount=type=cache,target=/app/deps \
    --mount=type=cache,target=/app/_build/prod \
      rm -rf /app/_build/prod/rel && \
      mix do deps.get --only prod, release && \
      # copy out of the cache so it is available
      cp -r /app/_build/prod/rel/spendable ./release

FROM ubuntu:20.04 AS app

ENV LANG=C.UTF-8

RUN set -xe \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends openssl \
  && useradd --create-home -u 1000 app \
  && rm -rf /var/lib/apt/lists/*

USER app
WORKDIR /home/app

COPY --from=build --chown=app:app /app/release ./
COPY --chown=app:app .devops/entrypoint.sh .
CMD ["./entrypoint.sh"]
