import { gql } from '@apollo/client'

export const MAIN_QUERY = gql`
  query Main {
    currentUser {
      id
      spendable
    }
    budgets {
      id
      name
      balance
    }
  }
`

// 
// BUDGETS
//
export const GET_BUDGET = gql`
  query GetBudget($id: ID!) {
    budget(id: $id) {
      id
      name
      balance
      goal
      recentAllocations {
        id
        amount
        transaction {
          id
          name
          date
          reviewed
        }
      }
      allocationTemplateLines {
        id
        amount
        allocationTemplate {
          id
          name
        }
      }
    }
  }
`

export const CREATE_BUDGET = gql`
mutation CreateBudget($name: String!, $balance: Decimal!, $goal: Decimal) {
  createBudget(name: $name, balance: $balance, goal: $goal) {
    id
    name
    balance
    goal
  }
}
`

export const UPDATE_BUDGET = gql`
  mutation UpdateBudget($id: ID!, $name: String!, $balance: Decimal!, $goal: Decimal) {
    updateBudget(id: $id, name: $name, balance: $balance, goal: $goal) {
      id
      name
      balance
      goal
    }
  }
`

export const DELETE_BUDGET = gql`
  mutation DeleteBudget($id: ID!) {
    deleteBudget(id: $id) {
      id
    }
  }
`

//
// Allocations
//
export const ALLOCATION_FRAGMENT = gql`
  fragment AllocationFragment on Allocation {
    id
    amount
    budget {
      id
      name
    }
  }
`

export const GET_ALLOCATION = gql`
  ${ALLOCATION_FRAGMENT}
  query Allocation($id: ID!) {
    allocation(id: $id) {
      ...AllocationFragment
    }
  }
`

export const CREATE_ALLOCATION = gql`
  ${ALLOCATION_FRAGMENT}
  mutation CreateAllocation($transactionId: ID!, $amount: Decimal!, $budgetId: ID!) {
    createAllocation(transactionId: $transactionId, amount: $amount, budgetId: $budgetId) {
      ...AllocationFragment
    }
  }
`

export const UPDATE_ALLOCATION = gql`
  ${ALLOCATION_FRAGMENT}
  mutation UpdateAllocation($id: ID!, $amount: Decimal, $budgetId: ID) {
    updateAllocation(id: $id, amount: $amount, budgetId: $budgetId) {
      ...AllocationFragment
    }
  }
`

export const DELETE_ALLOCATION = gql`
  mutation DeleteAllocation($id: ID!) {
    deleteAllocation(id: $id) {
      id
    }
  }
`

//
// Transasctions
//
export const TRANSACTION_FRAGMENT = gql`
${ALLOCATION_FRAGMENT}
fragment TransactionFragment on Transaction {
  id
  name
  note
  amount
  date
  reviewed
  allocations {
    ...AllocationFragment
  }
}
`

export const LIST_TRANSACTIONS = gql`
  query ListTransactions($offset: Int){
    transactions(offset: $offset) {
      id
      name
      amount
      date
      reviewed
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
  mutation CreateTransaction($amount: String!, $name: String, $date: String!, $note: String, $reviewed: Boolean!, $categoryId: ID, $allocations: [AllocationInputObject!]) {
    createTransaction(
      amount: $amount
      name: $name
      date: $date
      note: $note
      reviewed: $reviewed
      categoryId: $categoryId
      allocations: $allocations
    ) {
      ...TransactionFragment
    }
  }
`

export const UPDATE_TRANSACTION = gql`
  ${TRANSACTION_FRAGMENT}
  mutation UpdateTransaction($id: ID!, $amount: String, $name: String, $date: String, $note: String, $reviewed: Boolean, $allocations: [AllocationInputObject!]) {
    updateTransaction(
      id: $id
      amount: $amount
      name: $name
      date: $date
      note: $note
      reviewed: $reviewed
      allocations: $allocations
    ) {
      ...TransactionFragment
    }
  }
`

export const DELETE_TRANSACTION = gql`
  mutation DeleteTransaction($id: ID!) {
    deleteTransaction(id: $id) {
      id
    }
  }
`

