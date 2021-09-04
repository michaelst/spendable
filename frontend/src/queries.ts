import { gql } from '@apollo/client'

export const MAIN_SCREEN_QUERY = gql`
  query MainScreen {
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