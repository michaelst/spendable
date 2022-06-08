import React, { useCallback, useState } from 'react'
import { faExclamationCircle } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { ListBankMembers_bankMembers, ListBankMembers_bankMembers_bankAccounts } from '../graphql/ListBankMembers'
import formatCurrency from '../utils/formatCurrency'
import { Form } from 'react-bootstrap'
import { useLazyQuery, useMutation } from '@apollo/client'
import { UpdateBankAccount } from '../graphql/UpdateBankAccount'
import { GET_BANK_MEMBER_PLAID_LINK_TOKEN, UPDATE_BANK_ACCOUNT } from '../queries'
import { GetBankMemberPlaidLinkToken } from '../graphql/GetBankMemberPlaidLinkToken'
import { usePlaidLink, PlaidLinkOnSuccess, PlaidLinkOptions } from 'react-plaid-link'

const BankMemberRow = (bankMember: ListBankMembers_bankMembers) => {
  return (
    <div className="bg-white mb-4">
      <div className="flex flex-row justify-between border-b p-4">
        <div className="flex items-center">
          <img src={`data:image/png;base64,${bankMember.logo}`} alt="bank logo" className="h-8 mr-2" />
          {bankMember.name}
        </div>
        <div className="flex items-center">
          {bankMember.status !== "CONNECTED" && (
            <PlaidLinkWithOAuth id={bankMember.id} />
          )}
        </div>
      </div>
      <div className="pb-3">
        {[...bankMember.bankAccounts]
          .sort((a, b) => (a.sync === b.sync) ? 0 : a.sync ? -1 : 1)
          .map(account => <BankAccountRow key={account.id} {...account} />)}
      </div>
    </div>
  )
}

const BankAccountRow = (bankAccount: ListBankMembers_bankMembers_bankAccounts) => {
  const [updateBankAccount] = useMutation<UpdateBankAccount>(UPDATE_BANK_ACCOUNT)

  return (
    <div className="flex flex-row justify-between px-4 pt-3">
      <div className="flex items-center">
        {bankAccount.name}
      </div>
      <div className="flex items-center">
        {formatCurrency(bankAccount.balance)}
        <Form.Check
          checked={bankAccount.sync}
          onChange={e => updateBankAccount({ variables: { id: bankAccount.id, input: { sync: e.currentTarget.checked } } })}
          type="switch"
          className="ml-2"
        />
      </div>
    </div>
  )
}

const PlaidLinkWithOAuth = ({ id }: { id: string }) => {
  const [token, setToken] = useState<string | null>(null)
  const isOAuthRedirect = window.location.href.includes('?oauth_state_id=')

  const [loadToken] = useLazyQuery<GetBankMemberPlaidLinkToken>(GET_BANK_MEMBER_PLAID_LINK_TOKEN, {
    variables: { id: id },
    fetchPolicy: 'no-cache'
  })

  React.useEffect(() => {
    if (isOAuthRedirect) {
      setToken(localStorage.getItem('link_token'))
      return
    }

    const createLinkToken = async () => {
      loadToken().then(({ data }) => {
        if (data) {
          setToken(data.bankMember.plaidLinkToken)
          localStorage.setItem('link_token', data.bankMember.plaidLinkToken)
        }
      })
    }

    createLinkToken()
  }, [isOAuthRedirect, loadToken])

  const onSuccess = useCallback<PlaidLinkOnSuccess>((publicToken, metadata) => {
    console.log(publicToken, metadata)
  }, [])

  const config: PlaidLinkOptions = {
    token,
    onSuccess,
  }

  if (isOAuthRedirect) {
    config.receivedRedirectUri = window.location.href
  }

  const { open, ready } = usePlaidLink(config)

  React.useEffect(() => {
    if (isOAuthRedirect && ready) {
      open()
    }
  }, [ready, open, isOAuthRedirect])

  return (
    <button className="text-red-500" onClick={() => open()}>
      Reconnect
      <FontAwesomeIcon icon={faExclamationCircle} className="ml-2" />
    </button>
  )
}

export default BankMemberRow
