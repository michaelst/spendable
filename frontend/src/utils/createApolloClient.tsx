import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, concat } from '@apollo/client'
import { setContext } from '@apollo/client/link/context'
import { offsetLimitPagination } from '@apollo/client/utilities'
import Decimal from 'decimal.js-light'
import auth from '@react-native-firebase/auth'
import { DateTime } from 'luxon'

const createApolloClient = () => {
  const httpLink = new HttpLink({ uri: 'https://spendable.money/graphql' })

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
      Allocation: {
        fields: {
          amount: {
            read(amount) {
              return new Decimal(amount)
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
    link: concat(authLink, httpLink)
  })
}

export default createApolloClient
