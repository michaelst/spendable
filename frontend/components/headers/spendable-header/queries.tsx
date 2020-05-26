import { gql } from '@apollo/client'

export const GET_SPENDABLE = gql`
  query CurrentUser{
    currentUser {
      spendable
    }
  }
`