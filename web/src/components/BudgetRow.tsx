import React from 'react'
import formatCurrency from '../utils/formatCurrency'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { Badge } from 'react-bootstrap'

export type BudgetRowItem = {
  id: string
  title: string
  amount: Decimal
  subText: string
  archivedAt: DateTime | null
  onClick: () => void
}

type BudgetRowProps = {
  budget: BudgetRowItem
}

const BudgetRow = ({ budget }: BudgetRowProps) => {
  return (
    <div className="border-b bg-white p-8 w-100 cursor-pointer" onClick={budget.onClick}>
    <div className="flex flex-row justify-between">
      <div className="flex items-center">
        {budget.title}
        {budget.archivedAt && <Badge bg="secondary" className="ml-2">Archived</Badge>}
      </div>
      <div className="flex items-center">
        <div className="flex flex-col items-end mr-4">
          <div>{formatCurrency(budget.amount)}</div>
          <div className="text-xs text-slate-500 font-light">{budget.subText}</div>
        </div>
        <FontAwesomeIcon icon={faAngleRight} className="text-slate-500" />
      </div>
    </div>
  </div>
  )
}

export default BudgetRow