%{
  configs: [
    %{
      name: "default",
      strict: true,
      files: %{
        included: ["mix.exs", "lib/", "priv/repo/migrations/", "test/"],
        excluded: []
      },
      requires: ["./lib/spendable_credo/checks/**/*.ex"],
      color: true,
      checks: %{
        enabled: [
          #
          ## Custom Checks
          #
          {SpendableCredo.Checks.ActionModuleNaming, []},
          {SpendableCredo.Checks.BindFieldsAtOrigin, []},
          {SpendableCredo.Checks.InlineListShapeInAssert, []},
          {SpendableCredo.Checks.InlinePinnedFieldsInAssert, []},
          {SpendableCredo.Checks.LiveViewCallbackOrder, []},
          {SpendableCredo.Checks.LiveViewHandleParams, []},
          {SpendableCredo.Checks.MigrationTimestamps, []},
          {SpendableCredo.Checks.NilsLastInCase, []},
          {SpendableCredo.Checks.NoActionOrUtilAlias, []},
          {SpendableCredo.Checks.NoAssign2, []},
          {SpendableCredo.Checks.NoFunctionsInTests, []},
          {SpendableCredo.Checks.NoSigilWordLists, []},
          # {SpendableCredo.Checks.NoSetupInTests, []},
          {SpendableCredo.Checks.PipeIntoNoreplyOk, []},
          {SpendableCredo.Checks.PreferPositiveTypeGuard, []},
          {SpendableCredo.Checks.PrivateFunctionsLast, []},

          #
          ## Consistency Checks
          #
          {Credo.Check.Consistency.ExceptionNames, []},
          {Credo.Check.Consistency.LineEndings, []},
          {Credo.Check.Consistency.SpaceAroundOperators, []},
          {Credo.Check.Consistency.SpaceInParentheses, []},
          {Credo.Check.Consistency.TabsOrSpaces, []},
          {Credo.Check.Consistency.UnusedVariableNames, []},

          #
          ## Design Checks
          #
          # You can customize the priority of any check
          # Priority values are: `low, normal, high, higher`
          #
          {Credo.Check.Design.DuplicatedCode, [mass_threshold: 65]},
          {Credo.Check.Design.TagFIXME, []},

          #
          ## Readability Checks
          #
          # Credo.Check.Readability.AliasAs
          {Credo.Check.Readability.FunctionNames, []},
          {Credo.Check.Readability.ModuleAttributeNames, []},
          {Credo.Check.Readability.ModuleNames, []},
          {Credo.Check.Readability.ParenthesesInCondition, []},
          {Credo.Check.Readability.PredicateFunctionNames, []},
          {Credo.Check.Readability.RedundantBlankLines, []},
          {Credo.Check.Readability.Semicolons, []},
          {Credo.Check.Readability.SeparateAliasRequire, []},
          {Credo.Check.Readability.SpaceAfterCommas, []},
          {Credo.Check.Readability.VariableNames, []},
          {Credo.Check.Readability.WithCustomTaggedTuple, []},

          #
          ## Refactoring Opportunities
          #
          {Credo.Check.Refactor.ABCSize,
           [max_size: 80, files: %{excluded: ["priv/repo/migrations/"]}]},
          {Credo.Check.Refactor.AppendSingleItem, []},
          {Credo.Check.Refactor.Apply, []},
          {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 15},
          {Credo.Check.Refactor.DoubleBooleanNegation, []},
          {Credo.Check.Refactor.FilterFilter, []},
          {Credo.Check.Refactor.FilterReject, []},
          {Credo.Check.Refactor.FunctionArity, []},
          {Credo.Check.Refactor.IoPuts, []},
          {Credo.Check.Refactor.LongQuoteBlocks, []},
          {Credo.Check.Refactor.MapMap, []},
          {Credo.Check.Refactor.MatchInCondition, []},
          {Credo.Check.Refactor.NegatedIsNil, []},
          {Credo.Check.Refactor.Nesting, [max_nesting: 3]},
          {Credo.Check.Refactor.PassAsyncInTestCases,
           [
             files: %{included: ["lib/**/*_test.exs"]}
           ]},
          {Credo.Check.Refactor.RejectFilter, []},
          {Credo.Check.Refactor.RejectReject, []},

          #
          ## Warnings
          #
          {Credo.Check.Warning.ApplicationConfigInModuleAttribute, []},
          {Credo.Check.Warning.BoolOperationOnSameValues, []},
          {Credo.Check.Warning.ExpensiveEmptyEnumCheck, []},
          {Credo.Check.Warning.IExPry, []},
          {Credo.Check.Warning.IoInspect, []},
          {Credo.Check.Warning.LeakyEnvironment, []},
          {Credo.Check.Warning.MapGetUnsafePass, []},
          {Credo.Check.Warning.MixEnv, []},
          {Credo.Check.Warning.OperationOnSameValues, []},
          {Credo.Check.Warning.OperationWithConstantResult, []},
          {Credo.Check.Warning.UnsafeExec, []},
          {Credo.Check.Warning.UnsafeToAtom, []},
          {Credo.Check.Warning.UnusedEnumOperation, []},
          {Credo.Check.Warning.UnusedFileOperation, []},
          {Credo.Check.Warning.UnusedKeywordOperation, []},
          {Credo.Check.Warning.UnusedListOperation, []},
          {Credo.Check.Warning.UnusedPathOperation, []},
          {Credo.Check.Warning.UnusedRegexOperation, []},
          {Credo.Check.Warning.UnusedStringOperation, []},
          {Credo.Check.Warning.UnusedTupleOperation, []},
          {Credo.Check.Warning.WrongTestFileExtension, []},

          # JUMP credo rules
          {Jump.CredoChecks.AssertElementSelectorCanNeverFail, []},
          {Jump.CredoChecks.AvoidFunctionLevelElse, []},
          {Jump.CredoChecks.AvoidLoggerConfigureInTest, []},
          {Jump.CredoChecks.DoctestIExExamples,
           [
             derive_test_path: &String.replace_trailing(&1, ".ex", "_test.exs")
           ]},
          {Jump.CredoChecks.ForbiddenFunction,
           functions: [
             {:erlang, :binary_to_term,
              "Use Plug.Crypto.non_executable_binary_to_term/2 instead."}
           ]},
          {Jump.CredoChecks.LiveViewFormCanBeRehydrated, []},
          {Jump.CredoChecks.PreferChangeOverUpDownMigrations, []},
          {Jump.CredoChecks.PreferTextColumns, []},
          {Jump.CredoChecks.TestHasNoAssertions, []},
          {Jump.CredoChecks.TooManyAssertions, [max_assertions: 20]},
          {Jump.CredoChecks.TopLevelAliasImportRequire, []},
          {Jump.CredoChecks.VacuousTest,
           [
             # Additional library namespaces whose calls should not count
             # as production code. Defaults to []
             library_modules: [
               Broadway,
               Ecto,
               Jason,
               Phoenix,
               Plug
             ]
           ]},
          {Jump.CredoChecks.WeakAssertion, []}
        ]
      }
    }
  ]
}
