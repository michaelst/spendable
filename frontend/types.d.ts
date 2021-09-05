type Decimal = import('decimal.js-light').Decimal

type RootStackParamList = {
  Main: undefined,
  Expenses: undefined,
  Expense: { budgetId: string },
  'Create Expense': undefined,
  'Edit Expense': { budgetId: string }
}

type UseNavigationProp = StackNavigationProp<RootStackParamList>