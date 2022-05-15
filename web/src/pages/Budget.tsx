import React, { useState } from 'react';
import { useQuery } from '@apollo/client';
import { DateTime } from 'luxon'
import Decimal from 'decimal.js-light'
import { useNavigate, useParams } from "react-router-dom";

import { Main as Data } from '../graphql/Main';
import { GET_BUDGET, MAIN_QUERY } from '../queries';
import BudgetRow from '../components/BudgetRow';
import { amount, subText } from '../utils/budgetUtils';
import { GetBudget } from '../graphql/GetBudget';
import formatCurrency from '../utils/formatCurrency';
import Row, { RowProps } from '../components/Row';

function Budget() {
  const { id } = useParams()
  const [activeMonth, setActiveMonth] = useState(DateTime.now().startOf('month'))
  const navigate = useNavigate()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const { data } = useQuery<GetBudget>(GET_BUDGET, {
    variables: { 
      id: id, 
      startDate: activeMonth.toFormat('yyyy-MM-dd') ,
      endDate: activeMonth.endOf('month').toFormat('yyyy-MM-dd') 
    }
  })

  if (!data) return null

  const balance = {
    key: 'balance',
    leftSide: 'Balance',
    rightSide: formatCurrency(data.budget.balance)
  }

  const spent = {
    key: 'spent',
    leftSide: 'Spent',
    rightSide: formatCurrency(data.budget.spent)
  }

  const detailLines: RowProps[] = []

  if (activeMonthIsCurrentMonth && !data.budget.trackSpendingOnly) detailLines.push(balance)
  detailLines.push(spent)

  

  return (
    <div className="flex flex-col items-center pt-16">
      {detailLines.map(line => <Row {...line} />)}
    </div>
  )
}

export default Budget;
