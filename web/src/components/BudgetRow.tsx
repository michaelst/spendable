import React from 'react'
import { useMutation } from '@apollo/client'
import formatCurrency from '../utils/formatCurrency'
import { DELETE_BUDGET } from '../queries'
import { DeleteBudget } from '../graphql/DeleteBudget'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'

export type BudgetRowItem = {
  id: string
  title: string
  amount: Decimal
  subText: string
  hideDelete?: boolean
  onClick: () => void
}

type BudgetRowProps = {
  budget: BudgetRowItem
}

const BudgetRow = ({ budget }: BudgetRowProps) => {
  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: budget.id },
    update(cache, { data }) {
      const { deleteBudget }: DeleteBudget = data
      cache.evict({ id: 'Budget:' + deleteBudget?.result?.id })
      cache.gc()
    }
  })

  if (budget.hideDelete) return <Row budget={budget} />

  return (
    <Row budget={budget} />
  )
}

const Row = ({ budget: { title, amount, subText, onClick } }: BudgetRowProps) => {
  // const border = amount.isNegative() ? 'border border-red-500' : ''

  return (
    <div className="border-b bg-white p-8 w-1/2 cursor-pointer" onClick={onClick}>
      <div className="flex flex-row justify-between">
        <div className="flex items-center">
          {title}
        </div>
        <div className="flex items-center">
          <div className="flex flex-col items-end mr-4">
            <div>{formatCurrency(amount)}</div>
            <div className="text-xs text-slate-500">{subText}</div>
          </div>
          <FontAwesomeIcon icon={faAngleRight} className="text-slate-500" />
        </div>
      </div>
    </div>
  )
}

export default BudgetRow