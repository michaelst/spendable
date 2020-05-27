import Constants from 'expo-constants'

const ENV = {
  dev: {
    apiUrl: 'https://spendable.money/graphql'
  },
  prod: {
    apiUrl: 'https://spendable.money/graphql'
  }
}

type ENV = {
  apiUrl: string
}

function getEnvVars(env = ''): ENV {
  if (env.indexOf('prod') !== -1) return ENV.prod
  return ENV.dev
}


export default getEnvVars(Constants.manifest.releaseChannel)