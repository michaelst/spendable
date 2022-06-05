import React from 'react'
import { faAngleRight, faExclamationCircle } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { ListBankMembers_bankMembers, ListBankMembers_bankMembers_bankAccounts } from '../graphql/ListBankMembers'
import formatCurrency from '../utils/formatCurrency'
import { Form } from 'react-bootstrap'
import { useMutation } from '@apollo/client'
import { UpdateBankAccount } from '../graphql/UpdateBankAccount'
import { UPDATE_BANK_ACCOUNT } from '../queries'

const BankMemberRow = (bankMember: ListBankMembers_bankMembers) => {
  return (
    <div className="bg-white mb-4">
      <div className="flex flex-row justify-between border-b p-4">
        <div className="flex items-center">
          <img src={`data:image/png;base64,${bankMember.logo}`} alt="bank logo" className="h-8 mr-2" />
          {bankMember.name}
        </div>
        <div className="flex items-center">
          {bankMember.status != "CONNECTED" && (
            <div className="text-red-500">
              Reconnect
              <FontAwesomeIcon icon={faExclamationCircle} className="ml-2" />
            </div>
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

export default BankMemberRow
