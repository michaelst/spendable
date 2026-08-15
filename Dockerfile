FROM node:26-alpine AS node-builder

# Node 26 no longer bundles corepack.
RUN npm install -g pnpm@10.20.0

RUN mkdir -p /app/assets
WORKDIR /app

COPY assets/package.json assets/pnpm-lock.yaml ./assets/
RUN cd assets && pnpm install --prod --frozen-lockfile

COPY assets assets

FROM hexpm/elixir:1.20.3-erlang-29.0.5-ubuntu-noble-20260730.1 AS build

RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/runtime.exs ./config/

COPY --from=node-builder /app/assets ./assets
COPY lib lib
COPY priv priv
COPY rel rel

RUN --mount=type=cache,target=/app/deps \
    --mount=type=cache,target=/app/_build/prod \
      rm -rf /app/_build/prod/rel && \
      mix do deps.clean tailwind, deps.get --only prod, clean, assets.deploy, release && \
      # copy out of the cache so it is available
      cp -r /app/_build/prod/rel/spendable ./release

FROM ubuntu:24.04 AS app

ENV LANG=C.UTF-8

RUN set -xe \
  && apt-get update \
  && apt-get -y upgrade \
  && apt-get install -y --no-install-recommends openssl ca-certificates \
  # ubuntu:24.04 ships a default `ubuntu` user occupying uid 1000
  && userdel -r ubuntu \
  && useradd --create-home -u 1000 app \
  && rm -rf /var/lib/apt/lists/*

USER app
WORKDIR /home/app

COPY --from=build --chown=app:app /app/release ./

CMD ["./bin/spendable", "start"]
