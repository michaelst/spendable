import { gql } from '@apollo/client'

export const LIST_TRANSACTIONS = gql`
  query ListTransactions($offset: Int!){
    transactions(offset: $offset) {
      id
      name
      amount
      date
    }
  }
`

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

export const TRANSACTION_FRAGMENT = gql`
  ${ALLOCATION_FRAGMENT}
  fragment TransactionFragment on Transaction {
    id
    name
    note
    amount
    date
    allocations {
      ...AllocationFragment
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
  mutation CreateTransaction($amount: String!, $name: String, $date: String, $note: String, $categoryId: ID, $allocations: [AllocationInputObject!]!) {
    createTransaction(
      amount: $amount
      name: $name
      date: $date
      note: $note
      categoryId: $categoryId
      allocations: $allocations
    ) {
      ...TransactionFragment
    }
  }
`

export const UPDATE_TRANSACTION = gql`
  ${TRANSACTION_FRAGMENT}
  mutation UpdateTransaction($id: ID!, $amount: String, $name: String, $date: String, $note: String, $allocations: [AllocationInputObject!]) {
    updateTransaction(
      id: $id
      amount: $amount
      name: $name
      date: $date
      note: $note
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