FROM hexpm/elixir:1.16.2-erlang-26.2.2-ubuntu-focal-20240123 AS build

RUN apt-get update -y && apt-get install -y build-essential git \
    && apt-get clean && rm -f /var/lib/apt/lists/*_*

WORKDIR /app

RUN mix local.hex --force && \
    mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
COPY config/config.exs config/prod.exs config/runtime.exs ./config/

COPY assets assets
COPY lib lib
COPY priv priv
COPY rel rel
COPY protobuf protobuf

RUN --mount=type=cache,target=/app/deps \
    --mount=type=cache,target=/app/_build/prod \
      rm -rf /app/_build/prod/rel && \
      mix do deps.clean tailwind, deps.get --only prod, clean, assets.deploy, release && \
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

CMD ["./bin/spendable", "start"]
