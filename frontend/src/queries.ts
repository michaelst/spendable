import { gql } from '@apollo/client'

export const MAIN_QUERY = gql`
  query Main($month: Date!) {
    currentUser {
      id
      spendable
      spentByMonth {
        month
        spent
      }
    }
    budgets(sort: [{ field: NAME }]) {
      id
      name
      balance
      trackSpendingOnly
      spent(month: $month)
    }
  }
`

// 
// BUDGETS
//
export const GET_BUDGET = gql`
  query GetBudget($id: ID!, $startDate: Date!, $endDate: Date!) {
    budget(id: $id) {
      id
      name
      adjustment
      balance
      trackSpendingOnly
      spent(month: $startDate)
      budgetAllocations(
        limit: 100
        filter: {
          transaction: {
            and: [
              { date: { greaterThanOrEqual: $startDate } }
              { date: { lessThanOrEqual: $endDate } }
            ]
          }
        }
      ) {
        id
        amount
        transaction {
          id
          name
          date
          reviewed
        }
      }
      budgetAllocationTemplateLines {
        id
        amount
        budgetAllocationTemplate {
          id
          name
        }
      }
    }
  }
`

export const CREATE_BUDGET = gql`
mutation CreateBudget($input: CreateBudgetInput) {
  createBudget(input: $input) {
    result {
      id
    }
  }
}
`

export const UPDATE_BUDGET = gql`
  mutation UpdateBudget($id: ID!, $input: UpdateBudgetInput) {
    updateBudget(id: $id, input: $input) {
      result {
        id
        name
        balance
        trackSpendingOnly
      }
    }
  }
`

export const DELETE_BUDGET = gql`
  mutation DeleteBudget($id: ID!) {
    deleteBudget(id: $id) {
      result {
        id
      }
    }
  }
`

//
// Budget Allocations
//
export const BUDGET_ALLOCATION_FRAGMENT = gql`
  fragment BudgetAllocationFragment on BudgetAllocation {
    id
    amount
    budget {
      id
      name
    }
  }
`

export const GET_BUDGET_ALLOCATION = gql`
  ${BUDGET_ALLOCATION_FRAGMENT}
  query BudgetAllocation($id: ID!) {
    budgetAllocation(id: $id) {
      ...BudgetAllocationFragment
    }
  }
`

export const CREATE_BUDGET_ALLOCATION = gql`
  ${BUDGET_ALLOCATION_FRAGMENT}
  mutation CreateBudgetAllocation($input: CreateBudgetAllocationInput) {
    createBudgetAllocation(input: $input) {
      result {
        ...BudgetAllocationFragment
      }
    }
  }
`

export const UPDATE_BUDGET_ALLOCATION = gql`
  ${BUDGET_ALLOCATION_FRAGMENT}
  mutation UpdateBudgetAllocation($id: ID!, $input: UpdateBudgetAllocationInput) {
    updateBudgetAllocation(id: $id, input: $input) {
      result {
        ...BudgetAllocationFragment
      }
    }
  }
`

export const DELETE_BUDGET_ALLOCATION = gql`
  mutation DeleteBudgetAllocation($id: ID!) {
    deleteBudgetAllocation(id: $id) {
      result {
        id
      }
    }
  }
`

//
// Transasctions
//
export const TRANSACTION_FRAGMENT = gql`
  ${BUDGET_ALLOCATION_FRAGMENT}
  fragment TransactionFragment on Transaction {
    id
    name
    note
    amount
    date
    reviewed
    budgetAllocations {
      ...BudgetAllocationFragment
    }
  }
`

export const LIST_TRANSACTIONS = gql`
  query ListTransactions($offset: Int){
    transactions(limit: 100, offset: $offset, sort: [{ field: DATE, order: DESC }]) {
      results {
        id
        name
        amount
        date
        reviewed
      }
    }
  }
`

export const GET_TRANSACTION = gql`
  ${TRANSACTION_FRAGMENT}
  query GetTransaction($id: ID!) {
    transaction(id: $id) {
      ...TransactionFragment
      bankTransaction {
        name
      }
    }
  }
`

export const CREATE_TRANSACTION = gql`
  ${TRANSACTION_FRAGMENT}
  mutation CreateTransaction($input: CreateTransactionInput) {
    createTransaction(input: $input) {
      result {
        ...TransactionFragment
      }
    }
  }
`

export const UPDATE_TRANSACTION = gql`
  ${TRANSACTION_FRAGMENT}
  mutation UpdateTransaction($id: ID!, $input: UpdateTransactionInput) {
    updateTransaction(id: $id, input: $input) {
      result {
        ...TransactionFragment
      }
    }
  }
`

export const DELETE_TRANSACTION = gql`
  mutation DeleteTransaction($id: ID!) {
    deleteTransaction(id: $id) {
      result {
        id
      }
    }
  }
`

//
// Banks
//
export const GET_PLAID_LINK_TOKEN = gql`
  query GetPlaidLinkToken{
    currentUser {
      id
      plaidLinkToken
    }
  }
`

export const GET_BANK_MEMBER_PLAID_LINK_TOKEN = gql`
  query GetBankMemberPlaidLinkToken($id: ID!) {
    bankMember(id: $id) {
      id
      plaidLinkToken
    }
  }
`
export const LIST_BANK_MEMBERS = gql`
  query ListBankMembers{
    bankMembers {
      id
      name
      status
      logo
    }
  }
`

export const GET_BANK_MEMBER = gql`
  query GetBankMember($id: ID!) {
    bankMember(id: $id) {
      id
      name
      status
      logo
      bankAccounts {
        id
        name
        sync
        balance
      }
    }
  }
`

export const CREATE_BANK_MEMBER = gql`
  mutation CreateBankMember($input: CreateBankMemberInput) {
    createBankMember(input: $input) {
      result {
        id
        name
        status
        logo
      }
    }
  }
`

export const UPDATE_BANK_ACCOUNT = gql`
  mutation UpdateBankAccount($id: ID!, $input: UpdateBankAccountInput) {
    updateBankAccount(id: $id, input: $input) {
      result {
        id
        sync
      }
    }
  }
`

//
// Notifications
//
export const GET_NOTIFICATION_SETTINGS = gql`
  query GetNotificationSettings($deviceToken: String!) {
    notificationSettings(deviceToken: $deviceToken) {
      id
      enabled
    }
  }
`

export const REGISTER_DEVICE_TOKEN = gql`
  mutation RegisterDeviceToken($input: RegisterDeviceTokenInput) {
    registerDeviceToken(input: $input) {
      result {
        id
        enabled
      }
    }
  }
`

export const UPDATE_NOTIFICATION_SETTINGS = gql`
  mutation UpdateNotificationSettings($id: ID!, $input: UpdateNotificationSettingsInput) {
    updateNotificationSettings(id: $id, input: $input) {
      result {
        id
        enabled
      }
    }
  }
`

//
// Budget Allocation Templates
//
export const BUDGET_ALLOCATION_TEMPLATE_FRAGMENT = gql`
  fragment BudgetAllocationTemplateFragment on BudgetAllocationTemplate {
    id
    name
    budgetAllocationTemplateLines {
      id
      amount
      budget {
        id
        name
      }
    }
  }
`

export const LIST_BUDGET_ALLOCATION_TEMPLATES = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_FRAGMENT}
  query ListBudgetAllocationTemplates{
    budgetAllocationTemplates {
      ...BudgetAllocationTemplateFragment
    }
  }
`

export const GET_BUDGET_ALLOCATION_TEMPLATE = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_FRAGMENT}
  query GetBudgetAllocationTemplate($id: ID!) {
    budgetAllocationTemplate(id: $id) {
      ...BudgetAllocationTemplateFragment
    }
  }
`

export const CREATE_BUDGET_ALLOCATION_TEMPLATE = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_FRAGMENT}
  mutation CreateBudgetAllocationTemplate($input: CreateBudgetAllocationTemplateInput) {
    createBudgetAllocationTemplate(input: $input) {
      result {
        ...BudgetAllocationTemplateFragment
      }
    }
  }
`

export const UPDATE_BUDGET_ALLOCATION_TEMPLATE = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_FRAGMENT}
  mutation UpdateBudgetAllocationTemplate($id: ID!, $input: UpdateBudgetAllocationTemplateInput) {
    updateBudgetAllocationTemplate(id: $id, input: $input) {
      result {
        ...BudgetAllocationTemplateFragment
      }
    }
  }
`

export const DELETE_BUDGET_ALLOCATION_TEMPLATE = gql`
  mutation DeleteBudgetAllocationTemplate($id: ID!) {
    deleteBudgetAllocationTemplate(id: $id) {
      result {
        id
      }
    }
  }
`

//
// Budget Allocation Template Lines
//
export const BUDGET_ALLOCATION_TEMPLATE_LINE_FRAGMENT = gql`
  fragment BudgetAllocationTemplateLineFragment on BudgetAllocationTemplateLine {
    id
    amount
    budget {
      id
      name
    }
    budgetAllocationTemplate {
      id
    }
  }
`

export const GET_BUDGET_ALLOCATION_TEMPLATE_LINE = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_LINE_FRAGMENT}
  query BudgetAllocationTemplateLine($id: ID!) {
    budgetAllocationTemplateLine(id: $id) {
      ...BudgetAllocationTemplateLineFragment
    }
  }
`

export const CREATE_BUDGET_ALLOCATION_TEMPLATE_LINE = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_LINE_FRAGMENT}
  mutation CreateBudgetAllocationTemplateLine($input: CreateBudgetAllocationTemplateLineInput) {
    createBudgetAllocationTemplateLine(input: $input) {
      result {
        ...BudgetAllocationTemplateLineFragment
      }
    }
  }
`

export const UPDATE_BUDGET_ALLOCATION_TEMPLATE_LINE = gql`
  ${BUDGET_ALLOCATION_TEMPLATE_LINE_FRAGMENT}
  mutation UpdateBudgetAllocationTemplateLine($id: ID!, $input: UpdateBudgetAllocationTemplateLineInput) {
    updateBudgetAllocationTemplateLine(id: $id, input: $input) {
      result {
        ...BudgetAllocationTemplateLineFragment
      }
    }
  }
`

export const DELETE_BUDGET_ALLOCATION_TEMPLATE_LINE = gql`
  mutation DeleteBudgetAllocationTemplateLine($id: ID!) {
    deleteBudgetAllocationTemplateLine(id: $id) {
      result {
        id
      }
    }
  }
`
