import React, { useState } from 'react';
import { useQuery } from '@apollo/client';
import { DateTime } from 'luxon'
import Decimal from 'decimal.js-light'
import { useNavigate, useSearchParams } from "react-router-dom";

import { Main as Data } from '../graphql/Main';
import { MAIN_QUERY } from '../queries';
import BudgetRow from '../components/BudgetRow';
import { amount, subText } from '../utils/budgetUtils';
import formatCurrency from '../utils/formatCurrency';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faArrowsRotate, faPlus } from '@fortawesome/free-solid-svg-icons';
import BudgetForm from '../components/BudgetForm';

function Budgets() {
  const [searchParams, setSearchParams] = useSearchParams()
  const monthFromSearchParams = searchParams.get("month")
  const monthForState = monthFromSearchParams ? DateTime.fromFormat(monthFromSearchParams, 'yyyy-MM-dd') : DateTime.now().startOf('month')
  const [activeMonth, setActiveMonth] = useState(monthForState)
  const [showAddBudget, setShowAddBudget] = useState(false)
  const navigate = useNavigate()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const { data, refetch } = useQuery<Data>(MAIN_QUERY, {
    variables: { month: activeMonth.toFormat('yyyy-MM-dd') }
  })

  const spentByMonth = data?.currentUser.spentByMonth.map(s => {
    return { ...s, month: DateTime.fromJSDate(s.month).startOf('month') }
  }) || []

  const budgets = (data?.budgets || [])
    .filter(budget => !budget.archivedAt || !budget.spent.isZero())
    .map(budget => {
      const item = {
        id: budget.id,
        title: budget.name,
        amount: amount(activeMonthIsCurrentMonth, budget, data?.currentUser.spendable || new Decimal(0)),
        subText: subText(activeMonthIsCurrentMonth, budget),
        archivedAt: budget.archivedAt,
        hideDelete: budget.name === "Spendable",
        onClick: () => navigate(`/budgets/${budget.id}?month=${activeMonth.toFormat('yyyy-MM-dd')}`)
      }

      return <BudgetRow key={budget.id} budget={item} />
    })

  return (
    <>
      <div className="flex flex-col items-center">
        <div className="w-1/2 p-3 mt-16 mb-8 bg-white">
          <div className="flex flex-row items-center overflow-scroll">
            {spentByMonth.map(item => {
              return (
                <div
                  key={item.month.toString()}
                  className={"py-3 px-4 cursor-pointer " + (item.month?.equals(activeMonth) ? "bg-blue-50" : "")}
                  onClick={() => {
                    if (!item.month) return
                    setActiveMonth(item.month)
                    setSearchParams({ month: item.month.toFormat('yyyy-MM-dd') })
                    refetch({ month: item.month.toFormat('yyyy-MM-dd') })
                  }}>
                  <div className="whitespace-nowrap">{item.month?.toFormat('MMM yyyy')}</div>
                  <div className="text-xs text-slate-500 font-light">{item.spent && formatCurrency(item.spent)}</div>
                </div>
              )
            })}
          </div>

        </div>
        <div className="flex flex-col items-center pb-16 overflow-scroll w-1/2">
          <div className="mb-2 bg-white ml-auto rounded-full p-2 px-3">
            <button className="mr-3" onClick={() => setShowAddBudget(true)}>
              <FontAwesomeIcon icon={faPlus} />
            </button>
            <button onClick={() => refetch()}>
              <FontAwesomeIcon icon={faArrowsRotate} />
            </button>
          </div>
          {budgets}
        </div>
      </div>

      <BudgetForm show={showAddBudget} setShow={setShowAddBudget} />
    </>
  )
}

export default Budgets;
