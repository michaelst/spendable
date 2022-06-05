import React, { Dispatch, SetStateAction, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { DELETE_TRANSACTION, MAIN_QUERY } from '../queries'
import { DateTime } from 'luxon'
import { faCheckCircle } from '@fortawesome/free-regular-svg-icons'
import { faAngleRight, faCircleXmark, faDotCircle, faEllipsis, faTrashCan } from '@fortawesome/free-solid-svg-icons'
import { DeleteTransaction } from '../graphql/DeleteTransaction'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'
import { Offcanvas } from 'react-bootstrap'
import Decimal from 'decimal.js-light'
import TransactionForm from './TransactionForm'

export type TransactionRowItem = {
  id: string
  name: string | null
  amount: Decimal
  date: Date
  reviewed: boolean
  hideDelete?: boolean
}

const TransactionRow = (transaction: TransactionRowItem) => {
  const [show, setShow] = useState(false)

  return (
    <>
      <div className="border-b bg-white p-8" onClick={() => setShow(true)}>
        <div className="flex flex-row justify-between">
          <div className="flex flex-col items-start">
            <div>{transaction.name}</div>
            <div className="text-xs text-slate-500">{DateTime.fromJSDate(transaction.date).toLocaleString(DateTime.DATE_MED)}</div>
          </div>

          <div className="flex items-center">
            <div className="flex flex-col items-end mr-2">
              <div>{formatCurrency(transaction.amount)}</div>
            </div>
            {transaction.reviewed && <FontAwesomeIcon icon={faCheckCircle} className="text-green-500" />}
            <FontAwesomeIcon icon={faAngleRight} className="text-slate-500 ml-2" />
          </div>
        </div>
      </div>

      <TransactionForm id={transaction.id} show={show} setShow={setShow} />
    </>
  )
}

export default TransactionRow