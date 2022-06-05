import React from 'react'
import Decimal from 'decimal.js-light'
import { useMutation } from '@apollo/client'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { DELETE_BUDGET_ALLOCATION_TEMPLATE } from '../queries'
import { DeleteBudgetAllocationTemplate } from '../graphql/DeleteBudgetAllocationTemplate'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'

export type TemplateRowItem = {
  key: string
  id: string
  name: string
  amount: Decimal
  hideDelete?: boolean
  onClick: () => void
}

const TemplateRow = (template: TemplateRowItem) => {
  const [deleteAllocationTemplate] = useMutation(DELETE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: { id: template.id },
    update(cache, { data }) {
      const { deleteBudgetAllocationTemplate }: DeleteBudgetAllocationTemplate = data
      cache.evict({ id: 'BudgetAllocationTemplate:' + deleteBudgetAllocationTemplate?.result?.id })
      cache.gc()
    }
  })

  if (template.hideDelete) return <Row {...template} />

  return (
    <Row {...template} />
  )
}

const Row = ({ name, amount, onClick}: TemplateRowItem) => {
  return (
    <div className="border-b bg-white p-8" onClick={onClick}>
      <div className="flex flex-row justify-between">
        <div className="flex items-center">
          {name}
        </div>
        <div className="flex items-center">
          <div className="flex flex-col items-end mr-4">
            <div>{formatCurrency(amount)}</div>
          </div>
          <FontAwesomeIcon icon={faAngleRight} />
        </div>
      </div>
    </div>
  )
}

export default TemplateRow
