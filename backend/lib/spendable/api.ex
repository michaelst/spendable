defmodule Spendable.Api do
  use Ash.Api,
    extensions: [AshGraphql.Api]

  resources do
    registry Spendable.Api.Registry
  end

  graphql do
    root_level_errors? true
    show_raised_errors? true
  end
end
