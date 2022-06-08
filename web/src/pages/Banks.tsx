import React, { useCallback, useState } from 'react'
import { useLazyQuery, useMutation, useQuery } from '@apollo/client'
import { ListBankMembers } from '../graphql/ListBankMembers'
import { CREATE_BANK_MEMBER, GET_PLAID_LINK_TOKEN, LIST_BANK_MEMBERS } from '../queries'
import BankMemberRow from '../components/BankMemberRow'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowsRotate, faPlus } from '@fortawesome/free-solid-svg-icons'
import { usePlaidLink, PlaidLinkOnSuccess, PlaidLinkOptions } from 'react-plaid-link'
import { GetPlaidLinkToken } from '../graphql/GetPlaidLinkToken'

function Banks() {
  const { data, refetch } = useQuery<ListBankMembers>(LIST_BANK_MEMBERS)

  return (
    <div className="flex flex-col items-center py-16">
      <div className="flex flex-col w-1/2">
        <div className="mb-2 bg-white ml-auto rounded-full p-2 px-3">
          <PlaidLinkWithOAuth />
          <button onClick={() => refetch()}>
            <FontAwesomeIcon icon={faArrowsRotate} />
          </button>
        </div>
        {data?.bankMembers.map(member => <BankMemberRow key={member.id} {...member} />)}
      </div>
    </div>
  )
}

const PlaidLinkWithOAuth = () => {
  const [token, setToken] = useState<string | null>(null)
  const isOAuthRedirect = window.location.href.includes('?oauth_state_id=')

  const [loadToken] = useLazyQuery<GetPlaidLinkToken>(GET_PLAID_LINK_TOKEN, { fetchPolicy: 'no-cache' })

  const [createBankMember] = useMutation(CREATE_BANK_MEMBER, {
    refetchQueries: [{ query: LIST_BANK_MEMBERS }]
  })

  React.useEffect(() => {
    if (isOAuthRedirect) {
      setToken(localStorage.getItem('link_token'))
      return
    }

    const createLinkToken = async () => {
      loadToken().then(({ data }) => {
        if (data) {
          setToken(data.currentUser.plaidLinkToken)
          localStorage.setItem('link_token', data.currentUser.plaidLinkToken)
        }
      })
    }

    createLinkToken()
  }, [isOAuthRedirect, loadToken])

  const onSuccess = useCallback<PlaidLinkOnSuccess>((publicToken) => {
    createBankMember({ variables: { input: { publicToken: publicToken } } })
      .catch(error => {
        console.log(error)
      })
  }, [createBankMember])

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
    <button className="mr-3" onClick={() => open()}>
      <FontAwesomeIcon icon={faPlus} />
    </button>
  )
}

export default Banks
