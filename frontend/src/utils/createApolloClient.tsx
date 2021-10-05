import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, concat } from '@apollo/client'
import { setContext } from '@apollo/client/link/context'
import { offsetLimitPagination } from '@apollo/client/utilities'
import Decimal from 'decimal.js-light'
import auth from '@react-native-firebase/auth'

const createApolloClient = () => {
  const httpLink = new HttpLink({ uri: 'https://114c-205-204-35-189.ngrok.io/graphql' })

  const authLink = setContext(async (_, { headers }) => {
    const user = auth().currentUser
  
    if (user) {
      const token = await user.getIdToken()
  
      return {
        headers: {
          ...headers,
          authorization: token ? `Bearer ${token}` : ''
        }
      }
    } else return { headers }
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
      BudgetAllocation: {
        fields: {
          amount: {
            read(amount) {
              return new Decimal(amount)
            }
          }
        }
      },
      BudgetAllocationTemplateLine: {
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
    link: concat(authLink, httpLink)
  })
}

export default createApolloClient
