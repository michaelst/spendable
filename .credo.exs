%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/"],
        excluded: []
      },
      strict: true,
      checks: [
        {Credo.Check.Readability.LargeNumbers, priority: :low, only_greater_than: 99_999},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Warning.LazyLogging, false}
      ]
    }
  ]
}
