import React, { useEffect, useState } from 'react'
import { useQuery } from '@apollo/client'
import { DateTime } from 'luxon'
import { useNavigate, useParams, useSearchParams } from "react-router-dom"
import { Line } from 'react-chartjs-2'
import {
  Chart as ChartJS,
  ChartEvent,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
} from 'chart.js'

import { GET_BUDGET } from '../queries'
import { GetBudget } from '../graphql/GetBudget'
import formatCurrency from '../utils/formatCurrency'
import TemplateRow, { TemplateRowItem } from '../components/TemplateRow'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'




function Budget() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const monthFromSearchParams = searchParams.get("month")
  const activeMonth = monthFromSearchParams ? DateTime.fromFormat(monthFromSearchParams, 'yyyy-MM-dd') : DateTime.now().startOf('month')
  const navigate = useNavigate()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const { data } = useQuery<GetBudget>(GET_BUDGET, {
    variables: {
      id: id,
      startDate: activeMonth.toFormat('yyyy-MM-dd'),
      endDate: activeMonth.endOf('month').toFormat('yyyy-MM-dd')
    }
  })

  var onLabelClick = (clickedMonth: DateTime) => {
    const id = window.location.pathname.split("/").pop()
    navigate(`/budgets/${id}?month=${clickedMonth.toFormat('yyyy-MM-dd')}`)
  }

  const LabelClick = {
    id: 'LabelClick',
    beforeEvent: function (chartInstance: ChartJS, { event }: { event: ChartEvent }) {
      const xAxis = chartInstance.scales.x

      const x = event.x
      const y = event.y
      const index = x && xAxis.getValueForPixel(x)
      const labels = chartInstance.data.labels

      if (event.type === 'click' && x && y && labels &&
        x <= xAxis.right && x >= xAxis.left &&
        y <= xAxis.bottom && y >= xAxis.top) {
        const label: string = labels[index!] as string

        const id = window.location.pathname.split("/").pop()
        navigate(`/budgets/${id}?month=${DateTime.fromFormat(label, 'MMM yyyy').toFormat('yyyy-MM-dd')}`)
      }
    }
  }

  useEffect(() => {
    ChartJS.register(
      CategoryScale,
      LinearScale,
      PointElement,
      LineElement,
      LabelClick
    )

    return ChartJS.unregister()
  }, [])

  if (!data) return null

  const allocationTemplateLines: TemplateRowItem[] =
    [...data.budget.budgetAllocationTemplateLines]
      .sort((a, b) => b.amount.comparedTo(a.amount))
      .map(line => ({
        key: line.id,
        id: line.budgetAllocationTemplate.id,
        name: line.budgetAllocationTemplate.name,
        amount: line.amount,
        hideDelete: true,
        onClick: () => navigate(`/templates/${line.budgetAllocationTemplate.id}`)
      }))

  const recentAllocations: TransactionRowItem[] =
    [...data.budget.budgetAllocations]
      .sort((a, b) => b.transaction.date.getTime() - a.transaction.date.getTime())
      .map(allocation => ({
        key: allocation.id,
        id: allocation.transaction.id,
        name: allocation.transaction.name,
        amount: allocation.amount,
        date: allocation.transaction.date,
        reviewed: allocation.transaction.reviewed,
      }))

  return (
    <div className="flex flex-col items-center py-16">
      <div className="flex flex-col w-[70%] bg-white">
        <div className="text-left p-4 border-b">
          <div className="flex flex-row justify-between">
            <div className="flex items-center font-bold">
              {data.budget.name}
            </div>
            <div className="flex items-center">
              <div className="flex flex-col items-end">
                {activeMonthIsCurrentMonth && !data.budget.trackSpendingOnly ? (
                  <>
                    <div className="font-bold">{formatCurrency(data.budget.balance)}</div>
                    <div className="text-xs text-slate-500">Balance</div>
                  </>
                ) : (
                  <>
                    <div className="font-bold">{formatCurrency(data.budget.spent.abs())}</div>
                    <div className="text-xs text-slate-500">Spent</div>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
        <div className="p-4">
          <Line
            height={200}
            options={{
              maintainAspectRatio: false,
              scales: {
                x: {
                  grid: { display: false, drawBorder: false },
                  ticks: {
                    maxRotation: 0,
                    color: c => c.tick.label == activeMonth.toFormat('MMM yyyy') ? "rgb(75, 145, 215)" : "#666",
                    font: {
                      weight: c => c.tick.label == activeMonth.toFormat('MMM yyyy') ? "bold" : "normal"
                    }
                  }
                },
                y: {
                  grid: { display: false, drawBorder: false },
                  ticks: { callback: value => "$" + value }
                }
              },
              datasets: {
                line: {
                  tension: 0.4,
                }
              }
            }}
            data={{
              labels: data.budget.spentByMonth.map(s => DateTime.fromJSDate(s.month).toFormat('MMM yyyy')),
              datasets: [{
                backgroundColor: 'rgb(75, 145, 215)',
                borderColor: 'rgb(75, 145, 215)',
                data: data.budget.spentByMonth.map(s => s.spent.abs().toNumber()),
              }]
            }} />
        </div>
        <div className="flex flex-row max-h-[90vh] border-t">
          <div className="w-1/2 overflow-scroll">
            <div className="py-2">Transactions</div>
            {recentAllocations.map(transaction => <TransactionRow {...transaction} />)}
          </div>
          <div className="w-1/2 border-l overflow-scroll pt-2">
            <div className="py-2">Templates</div>
            {allocationTemplateLines.map(template => <TemplateRow {...template} />)}
          </div>
        </div>
      </div>
    </div>
  )
}

export default Budget
