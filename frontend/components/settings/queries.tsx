import { gql } from "@apollo/client";

export const GET_PLAID_LINK_TOKEN = gql`
  query GetPlaidLinkToken{
    currentUser {
      id
      plaidLinkToken
    }
  }
`

export const GET_NOTIFICATION_SETTINGS = gql`
query GetNotificationSettings($deviceToken: String!) {
  notificationSettings(deviceToken: $deviceToken) {
    id
    enabled
  }
}
`

export const UPDATE_NOTIFICATION_SETTINGS = gql`
mutation UpdateNotificationSettings($id: ID!, $enabled: Boolean!) {
  updateNotificationSettings(id: $id, enabled: $enabled) {
    id
    enabled
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
        budget {
          id
        }
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
          goal
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

export const GET_TEMPLATE_LINE = gql`
  query AllocationTemplateLine($id: ID!) {
    allocationTemplateLine(id: $id) {
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