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

export const TRANSACTION_FRAGMENT = gql`
  fragment TransactionFragment on Transaction {
    id
    name
    note
    amount
    date
    allocations {
      id
      amount
      budget {
        id
        name
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
        pending
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
  mutation UpdateTransaction($id: ID!, $amount: String!, $name: String, $date: String, $note: String, $allocations: [AllocationInputObject!]!) {
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