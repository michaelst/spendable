export const openPlaidLink = (linkToken, onSuccess) => {
  const handler = Plaid.create({
    token: linkToken,
    onSuccess: onSuccess,
    onLoad: () => {},
    onExit: (err, metadata) => {},
    onEvent: (eventName, metadata) => {},
  })

  handler.open()
}
