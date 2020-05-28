import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, concat } from '@apollo/client'
import getEnvVars from './getEnvVars'
import Decimal from 'decimal.js-light'

const createApolloClient = (token: string | null) => {
  const httpLink = new HttpLink({ uri: getEnvVars.apiUrl })

  const authMiddleware = new ApolloLink((operation, forward) => {
    operation.setContext({
      headers: {
        authorization: token ? `Bearer ${token}` : null,
      }
    })

    return forward(operation)
  })

  const cache = new InMemoryCache({
    typePolicies: {
      Budget: {
        fields: {
          balance: {
            read(balance) {
              return new Decimal(balance)
            }
          },
          goal: {
            read(goal) {
              if (goal)  return new Decimal(goal)
              return null
            }
          },
        },
      },
      User: {
        fields: {
          spendable: {
            read(spendable) {
              return new Decimal(spendable)
            }
          }
        }
      },
      BankAccount: {
        fields: {
          balance: {
            read(balance) {
              return new Decimal(balance)
            }
          }
        }
      }
    },
  })

  return new ApolloClient({
    cache: cache,
    link: concat(authMiddleware, httpLink)
  })
}

export default createApolloClient
