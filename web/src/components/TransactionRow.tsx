import React from 'react'
import { useMutation } from '@apollo/client'
import { DELETE_TRANSACTION, MAIN_QUERY } from '../queries'
import { DateTime } from 'luxon'
import { faCheckCircle } from '@fortawesome/free-regular-svg-icons'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { DeleteTransaction } from '../graphql/DeleteTransaction'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'

export type TransactionRowItem = {
  key: string
  id: string
  title: string | null
  amount: Decimal
  transactionDate: Date
  transactionReviewed: boolean
  hideDelete?: boolean
  onClick: () => void
}

const TransactionRow = (transaction: TransactionRowItem) => {
  const [deleteTransaction] = useMutation(DELETE_TRANSACTION, {
    variables: { id: transaction.id },
    refetchQueries: [{ query: MAIN_QUERY }],
    update(cache, { data }) {
      const { deleteTransaction }: DeleteTransaction = data
      cache.evict({ id: 'Transaction:' + deleteTransaction?.result?.id })
      cache.gc()
    }
  })

  if (transaction.hideDelete) return <Row {...transaction} />

  return (
    <Row {...transaction} />
  )
}

const Row = ({ title, amount, transactionDate, transactionReviewed, onClick }: TransactionRowItem) => {
  return (
    <div className="border-b bg-white p-8 w-1/2" onClick={onClick}>
      <div className="flex flex-row justify-between">
        <div className="flex items-center">
          <div>{title}</div>
          <div>{DateTime.fromJSDate(transactionDate).toLocaleString(DateTime.DATE_MED)}</div>
        </div>

        <div className="flex items-center">
          <div className="flex flex-col items-end mr-4">
            <div>{formatCurrency(amount)}</div>
          </div>
          {transactionReviewed && <FontAwesomeIcon icon={faCheckCircle} />}
          <FontAwesomeIcon icon={faAngleRight} />
        </div>
      </div>
    </div>
  )
}

export default TransactionRow