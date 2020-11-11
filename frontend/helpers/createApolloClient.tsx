import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, concat } from '@apollo/client'
import { offsetLimitPagination } from '@apollo/client/utilities'
import Decimal from 'decimal.js-light'

const createApolloClient = (token: string | null) => {
  const httpLink = new HttpLink({ uri: 'https://spendable.money/graphql' })

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
      Query: {
        fields: {
          transactions: offsetLimitPagination()
        }
      },
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
      },
      AllocationTemplateLine: {
        fields: {
          amount: {
            read(amount) {
              return new Decimal(amount)
            }
          }
        }
      },
      Transaction: {
        fields: {
          amount: {
            read(amount) {
              return new Decimal(amount)
            }
          },
          date: {
            read(date) {
              return new Date(date)
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
