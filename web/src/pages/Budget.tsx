import React, { useEffect } from 'react'
import { useMutation, useQuery } from '@apollo/client'
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

import { GET_BUDGET, UPDATE_BUDGET } from '../queries'
import { GetBudget } from '../graphql/GetBudget'
import formatCurrency from '../utils/formatCurrency'
import TemplateRow, { TemplateRowItem } from '../components/TemplateRow'
import TransactionRow, { TransactionRowItem } from '../components/TransactionRow'
import Decimal from 'decimal.js-light'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faBoxArchive, faPencil } from '@fortawesome/free-solid-svg-icons'
import { Badge } from 'react-bootstrap'




function Budget() {
  const { id } = useParams()
  const [searchParams] = useSearchParams()
  const monthFromSearchParams = searchParams.get("month")
  const activeMonth = monthFromSearchParams ? DateTime.fromFormat(monthFromSearchParams, 'yyyy-MM-dd') : DateTime.now().startOf('month')
  const navigate = useNavigate()

  const activeMonthIsCurrentMonth = DateTime.now().startOf('month').equals(activeMonth)

  const { data: currentData, previousData } = useQuery<GetBudget>(GET_BUDGET, {
    variables: {
      id: id,
      startDate: activeMonth.toFormat('yyyy-MM-dd'),
      endDate: activeMonth.endOf('month').toFormat('yyyy-MM-dd')
    }
  })

  const [updateBudget] = useMutation(UPDATE_BUDGET)

  const archviveBudget = (archivedAt: DateTime) => {
    updateBudget({
      variables: {
        id: id,
        input: { archivedAt }
      }
    })
  }

  const data = currentData ?? previousData

  useEffect(() => {
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

    ChartJS.register(
      CategoryScale,
      LinearScale,
      PointElement,
      LineElement,
      LabelClick
    )

    return ChartJS.unregister()
  }, [navigate])

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
      {data.budget.name !== "Spendable" && !data.budget.archivedAt && (
        <div className="mb-2 bg-white ml-auto rounded-full p-2 px-3 mr-[15%]">
          <button className="mr-3" onClick={() => { }}>
            <FontAwesomeIcon icon={faPencil} />
          </button>
          <button className="" onClick={() => archviveBudget(DateTime.now())}>
            <FontAwesomeIcon icon={faBoxArchive} />
          </button>
        </div>)}
      <div className="flex flex-col w-[70%] bg-white">
        <div className="text-left p-4 border-b">
          <div className="flex flex-row justify-between">
            <div className="flex items-center font-bold">
              {data.budget.name}
              {data.budget.archivedAt && <Badge bg="secondary" className="ml-2">Archived</Badge>}
            </div>
            <div className="flex items-center">
              <div className="flex flex-col items-end">
                {activeMonthIsCurrentMonth && !data.budget.trackSpendingOnly ? (
                  <>
                    <div>{formatCurrency(data.budget.balance)}</div>
                    <div className="text-xs text-slate-500 font-light">Balance</div>
                  </>
                ) : (
                  <>
                    <div>{formatCurrency(data.budget.spent.abs())}</div>
                    <div className="text-xs text-slate-500 font-light">Spent</div>
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
                    color: c => c.tick.label === activeMonth.toFormat('MMM yyyy') ? "rgb(75, 145, 215)" : "#666",
                    font: {
                      family: "Oxygen",
                      weight: c => c.tick.label === activeMonth.toFormat('MMM yyyy') ? "700" : "300"
                    }
                  }
                },
                y: {
                  grid: { display: false, drawBorder: false },
                  ticks: {
                    maxTicksLimit: 6,
                    callback: value => formatCurrency(new Decimal(value), 0),
                    maxRotation: 0,
                    font: {
                      family: "Oxygen",
                      weight: "300"
                    }
                  }
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
