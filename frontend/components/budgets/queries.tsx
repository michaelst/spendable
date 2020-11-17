import { gql } from '@apollo/client'

export const LIST_BUDGETS = gql`
  query ListBudgets {
    budgets {
      id
      name
      balance
      goal
    }
  }
`

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