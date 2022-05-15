import React from 'react'
import { useMutation } from '@apollo/client'
import formatCurrency from '../utils/formatCurrency'
import { DELETE_BUDGET } from '../queries'
import { DeleteBudget } from '../graphql/DeleteBudget'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { Link } from 'react-router-dom'

export type BudgetRowItem = {
  id: string
  title: string
  amount: Decimal
  subText: string
  hideDelete?: boolean
  onPress: () => void
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

const Row = ({ budget: { id, title, amount, subText, onPress } }: BudgetRowProps) => {
  // const border = amount.isNegative() ? 'border border-red-500' : ''

  return (
    <div className="border-b bg-white p-8 w-1/2">
      <Link to={`/budgets/${id}`} >
        <div className="flex flex-row justify-between">
          <div className="flex items-center">
            <p>{title}</p>
          </div>
          <div className="flex items-center">
            <div className="flex flex-col items-end mr-4">
              <div className="font-bold">{formatCurrency(amount)}</div>
              <div className="text-xs">{subText}</div>
            </div>
            <FontAwesomeIcon icon={faAngleRight} />
          </div>
        </div>
      </Link>
    </div>
  )
}

export default BudgetRow