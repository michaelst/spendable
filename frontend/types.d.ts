type DateTime = import('luxon').DateTime
type Decimal = import('decimal.js-light').Decimal

type RootStackParamList = {
  'Main': undefined,
  'Budgets': undefined,
  'Budget': { budgetId: string },
  'Create Budget': undefined,
  'Edit Budget': { budgetId: string },
  'Transactions': undefined,
  'Transaction': { transactionId: string },
  'Create Transaction': undefined,
  'Spend From': { transactionId: string },
  'Create Allocation': { transactionId: string },
  'Edit Allocation': { allocationId: string },
  'Settings': undefined,
  'Banks': undefined,
  'Bank': { bankMemberId: string },
  'Templates': undefined,
  'Template': { templateId: string },
  'Create Template': undefined
  'Edit Template': { templateId: string }
  'Create Template Line': { templateId: string },
  'Edit Template Line': { lineId: string }
}

type NavigationProp = StackNavigationProp<RootStackParamList>