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

export const GET_TRANSACTION = gql`
  query GetTransaction($id: ID!) {
    transaction(id: $id) {
      name
      note
      amount
      date
      allocations {
        id
        budget {
          id
        }
        amount
      }
      category {
        id
      }
      bankTransaction {
        name
        pending
      }
    }
  }
`

export const CREATE_TRANSACTION = gql`
  mutation CreateTransaction($amount: String!, $name: String, $date: String, $note: String, $categoryId: ID, $allocations: [AllocationInputObject!]!) {
    createTransaction(
      amount: $amount
      name: $name
      date: $date
      note: $note
      categoryId: $categoryId
      allocations: $allocations
    ) {
      id
      name
      note
      amount
      date
      allocations {
        id
        budget {
          id
        }
        amount
      }
      category {
        id
      }
    }
  }
`

export const UPDATE_BUDGET = gql`
  mutation UpdateTransaction($id: ID!, $amount: String!, $name: String, $date: String, $note: String, $categoryId: ID, $allocations: [AllocationInputObject!]!) {
    updateTransaction(
      id: $id
      amount: $amount
      name: $name
      date: $date
      note: $note
      categoryId: $categoryId
      allocations: $allocations
    ) {
      id
      amount
      name
      date
      note
      category {
        id
      }
      allocations {
        id
        budget {
          id
        }
        amount
      }
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