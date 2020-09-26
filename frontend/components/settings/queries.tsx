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

export const LIST_TEMPLATES = gql`
  query ListAllocationTemplates{
    allocationTemplates {
      id
      name
      lines {
        amount
      }
    }
  }
`

export const GET_TEMPLATE = gql`
  query GetAllocationTemplate($id: ID!) {
    allocationTemplate(id: $id) {
      id
      name
      lines {
        id
        amount
        budget {
          id
          name
        }
      }
    }
  }
`

export const CREATE_TEMPLATE = gql`
  mutation CreateAllocationTemplate($name: String!, $lines: [AllocationTemplateLineInputObject]) {
    createAllocationTemplate(name: $name, lines: $lines) {
      id
      name
      lines {
          id
          amount
          budget {
              id
          }
      }
    }
  }
`

export const UPDATE_TEMPLATE = gql`
  mutation UpdateAllocationTemplate($id: ID!, $name: String!, $lines: [AllocationTemplateLineInputObject]) {
    updateAllocationTemplate(id: $id, name: $name, lines: $lines) {
      id
      name
      lines {
          id
          amount
          budget {
            id
          }
      }
    }
  }
`

export const DELETE_TEMPLATE = gql`
  mutation DeleteAllocationTemplate($id: ID!) {
    deleteAllocationTemplate(id: $id) {
      id
    }
  }
`

export const CREATE_TEMPLATE_LINE = gql`
  mutation CreateAllocationTemplateLine($budgetAllocationTemplateId: ID!, $amount: Decimal!, $budgetId: ID!) {
    createAllocationTemplateLine(budgetAllocationTemplateId: $budgetAllocationTemplateId, amount: $amount, budgetId: $budgetId) {
      id
      amount
      budget {
        id
      }
      allocationTemplate {
        id
      }
    }
  }
`

export const UPDATE_TEMPLATE_LINE = gql`
  mutation UpdateAllocationTemplateLine($id: ID!, $budgetAllocationTemplateId: ID, $amount: Decimal, $budgetId: ID) {
    updateAllocationTemplateLine(id: $id, budgetAllocationTemplateId: $budgetAllocationTemplateId, amount: $amount, budgetId: $budgetId) {
      id
      amount
      budget {
        id
      }
      allocationTemplate {
        id
      }
    }
  }
`

export const DELETE_TEMPLATE_LINE = gql`
  mutation DeleteAllocationTemplateLine($id: ID!) {
    deleteAllocationTemplateLine(id: $id) {
      id
    }
  }
`