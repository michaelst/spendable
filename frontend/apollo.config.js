module.exports = {
  client: {
    service: {
      url: 'https://spendable.money/graphql',
      headers: {
        authorization: `Bearer ${process.env.API_TOKEN}`
      }
    },
    includes: ['./src/queries.ts']
  }
}
