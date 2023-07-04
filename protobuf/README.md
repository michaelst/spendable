# Protos

## Setup

1. Install protobuf and buf

```
brew tap bufbuild/buf
brew install protobuf buf
```

1. Install the elixir plugin:

```bash
mix escript.install hex protobuf
asdf reshim elixir
```

1. Generate Protos

```bash
buf generate
```