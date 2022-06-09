import React, { useState } from 'react'
import { DateTime } from 'luxon'
import { faCheckCircle } from '@fortawesome/free-regular-svg-icons'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'
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
          <div className="flex flex-col items-start w-[70%]">
            <div className="whitespace-nowrap truncate w-full text-left">{transaction.name}</div>
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