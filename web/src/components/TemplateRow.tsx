import React from 'react'
import Decimal from 'decimal.js-light'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
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

  return (
    <div className="border-b bg-white p-8" onClick={template.onClick}>
      <div className="flex flex-row justify-between">
        <div className="flex items-center">
          {template.name}
        </div>
        <div className="flex items-center">
          <div className="flex flex-col items-end mr-4">
            <div>{formatCurrency(template.amount)}</div>
          </div>
          <FontAwesomeIcon icon={faAngleRight} />
        </div>
      </div>
    </div>
  )
}

export default TemplateRow
