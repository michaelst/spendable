import React, { useState } from 'react';
import { useQuery } from '@apollo/client';
import { DateTime } from 'luxon'
import Decimal from 'decimal.js-light'
import { useNavigate } from "react-router-dom";

import { Main as Data } from '../graphql/Main';
import { MAIN_QUERY } from '../queries';
import BudgetRow from '../components/BudgetRow';
import { amount, subText } from '../utils/budgetUtils';

function Budget() {
  const [activeMonth, setActiveMonth] = useState(DateTime.now().startOf('month'))
  const navigate = useNavigate()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const { data, loading, refetch } = useQuery<Data>(MAIN_QUERY, {
    variables: { month: activeMonth.toFormat('yyyy-MM-dd') }
  })

  const spentByMonth = data?.currentUser.spentByMonth.map(s => {
    return { ...s, month: DateTime.fromJSDate(s.month).startOf('month') }
  }) || []

  const budgets = (data?.budgets || []).map(budget => {
    const item = {
      id: budget.id,
      title: budget.name,
      amount: amount(activeMonthIsCurrentMonth, budget, data?.currentUser.spendable || new Decimal(0)),
      subText: subText(activeMonthIsCurrentMonth, budget),
      hideDelete: budget.name === "Spendable",
      onPress: () => navigate(`/budget/${budget.id}`)
    }

    return <BudgetRow budget={item} />
  })

  return <div>{budgets}</div>
}

export default Budget;
