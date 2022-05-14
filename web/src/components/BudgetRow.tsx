import React from 'react'
import { useMutation } from '@apollo/client'
import formatCurrency from '../utils/formatCurrency'
import { DELETE_BUDGET } from '../queries'
import { DeleteBudget } from '../graphql/DeleteBudget'

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

const Row = ({ budget: { title, amount, subText, onPress } }: BudgetRowProps) => {
  // const amountTextStyle = amount.isNegative() ? styles.dangerText : styles.text

  return (
    <div className='flex flex-row'>
      <div>
        <p>{title}</p>
      </div>
      <div>
        <p>{formatCurrency(amount)}</p>
        <p>{subText}</p>
      </div>
    </div>
  )
}

export default BudgetRow