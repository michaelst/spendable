import React from 'react';
import { useMutation, useQuery } from '@apollo/client';
import { ListBankMembers } from '../graphql/ListBankMembers';
import { CREATE_BANK_MEMBER, LIST_BANK_MEMBERS } from '../queries';
import BankMemberRow from '../components/BankMemberRow';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faArrowsRotate, faPlus } from '@fortawesome/free-solid-svg-icons';

function Banks() {
  const { data, refetch } = useQuery<ListBankMembers>(LIST_BANK_MEMBERS)
  //const { data: plaidData } = useQuery<GetPlaidLinkToken>(GET_PLAID_LINK_TOKEN, { fetchPolicy: 'no-cache' })

  const [createBankMember] = useMutation(CREATE_BANK_MEMBER, {
    refetchQueries: [{ query: LIST_BANK_MEMBERS }]
  })

  return (
    <div className="flex flex-col items-center py-16">
      <div className="flex flex-col w-1/2">
      <div className="mb-2 bg-white ml-auto rounded-full p-2 px-3">
          <button className="mr-3" onClick={() => {}}>
            <FontAwesomeIcon icon={faPlus} />
          </button>
          <button onClick={() => refetch()}>
            <FontAwesomeIcon icon={faArrowsRotate} />
          </button>
        </div>
        {data?.bankMembers.map(member => <BankMemberRow key={member.id} {...member} />)}
      </div>
    </div>
  )
}

export default Banks;
