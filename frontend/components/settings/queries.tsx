import { gql } from "@apollo/client";

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
mutation CreateBankMember($publicToken: String!) {
  createBankMember(publicToken: $publicToken) {
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

export const CREATE_PUBLIC_TOKEN = gql`
mutation CreatePublicToken($id: ID!) {
  createPublicToken(id: $id)
}
`

export const UPDATE_BANK_ACCOUNT = gql`
mutation UpdateBankAccount($id: ID!, $sync: Boolean!) {
  updateBankAccount(id: $id, sync: $sync) {
    id
    sync
  }
}
`