import { ApolloClient, InMemoryCache, HttpLink, ApolloLink, concat } from '@apollo/client'
import getEnvVars from './getEnvVars'

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

  return new ApolloClient({
    cache: new InMemoryCache(),
    link: concat(authMiddleware, httpLink)
  })
}

export default createApolloClient
