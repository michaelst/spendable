import React, { Dispatch, SetStateAction, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { DELETE_TRANSACTION, GET_TRANSACTION, LIST_BUDGETS, LIST_BUDGET_ALLOCATION_TEMPLATES, MAIN_QUERY, UPDATE_TRANSACTION } from '../queries'
import { DateTime } from 'luxon'
import { faCheckCircle } from '@fortawesome/free-regular-svg-icons'
import { faAngleRight, faCircleXmark } from '@fortawesome/free-solid-svg-icons'
import { DeleteTransaction } from '../graphql/DeleteTransaction'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'
import { Form, Offcanvas } from 'react-bootstrap'
import { GetTransaction, GetTransaction_transaction } from '../graphql/GetTransaction'
import { ListBudgets } from '../graphql/ListBudgets'
import { ListBudgetAllocationTemplates } from '../graphql/ListBudgetAllocationTemplates'
import Decimal from 'decimal.js-light'

export type TransactionRowItem = {
  id: string
  name: string | null
  amount: Decimal
  date: Date
  reviewed: boolean
  hideDelete?: boolean
}

type BudgetAllocationInput = {
  amount: string
  budget: {
    id: number
  }
}

const TransactionRow = (transaction: TransactionRowItem) => {
  const [show, setShow] = useState(false)

  const [deleteTransaction] = useMutation(DELETE_TRANSACTION, {
    variables: { id: transaction.id },
    refetchQueries: [{ query: MAIN_QUERY }],
    update(cache, { data }) {
      const { deleteTransaction }: DeleteTransaction = data
      cache.evict({ id: 'Transaction:' + deleteTransaction?.result?.id })
      cache.gc()
    }
  })

  return (
    <>
      <div className="border-b bg-white p-8 w-1/2" onClick={() => setShow(true)}>
        <div className="flex flex-row justify-between">
          <div className="flex flex-col items-start">
            <div>{transaction.name}</div>
            <div className="text-xs text-slate-500">{DateTime.fromJSDate(transaction.date).toLocaleString(DateTime.DATE_MED)}</div>
          </div>

          <div className="flex items-center">
            <div className="flex flex-col items-end mr-2">
              <div>{formatCurrency(transaction.amount)}</div>
            </div>
            {transaction.reviewed && <FontAwesomeIcon icon={faCheckCircle} className="text-green-500" />}
            <FontAwesomeIcon icon={faAngleRight} className="text-slate-500 ml-2" />
          </div>
        </div>
      </div>

      <Offcanvas show={show} onHide={() => setShow(false)} placement="end">
        <TransactionForm id={transaction.id} setShow={setShow} />
      </Offcanvas>
    </>
  )
}

const TransactionForm = ({ id, setShow }: { id: string, setShow: Dispatch<SetStateAction<boolean>> }) => {
  const [name, setName] = useState('')
  const [amount, setAmount] = useState('')
  const [date, setDate] = useState('')
  const [note, setNote] = useState('')
  const [reviewed, setReviewed] = useState(false)
  const [allocations, setAllocations] = useState<BudgetAllocationInput[]>([])

  const budgets = useQuery<ListBudgets>(LIST_BUDGETS)

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, {
    variables: { id: id },
    onCompleted: data => {
      setName(data.transaction.name ?? '')
      setAmount(data.transaction.amount.toDecimalPlaces(2).toFixed(2))
      setDate(DateTime.fromJSDate(data.transaction.date).toISODate())
      setNote(data.transaction.note ?? '')
      setReviewed(data.transaction.reviewed)
      setAllocations(data.transaction.budgetAllocations.map(a => ({ amount: a.amount.toDecimalPlaces(2).toFixed(2), budget: { id: parseInt(a.budget.id) } })))
    }
  })

  const [updateTransaction] = useMutation(UPDATE_TRANSACTION)

  if (!data) return null
  if (!budgets.data) return null

  const spendableId = budgets.data.budgets.find(b => b.name === "Spendable")!.id

  const split = () => {
    const allocatedAmount = allocations.reduce((acc, allocation) => acc.plus(allocation.amount), new Decimal(0))

    const newAllocations = [
      ...allocations,
      {
        amount: new Decimal(amount).minus(allocatedAmount).toDecimalPlaces(2).toFixed(2),
        budget: { id: parseInt(spendableId) }
      }
    ]

    setAllocations(newAllocations)
  }

  const saveAndClose = () => {
    updateTransaction({
      variables: {
        id: data.transaction.id,
        input: {
          amount: amount,
          date: date,
          name: name,
          note: note,
          reviewed: reviewed,
          budgetAllocations: allocations
        }
      }
    }).then(() => {
      setShow(false)
    }).catch(error => {
      console.log(error)
    })
  }

  return (
    <>
      <Offcanvas.Header closeButton>
        <Offcanvas.Title>Edit Transaction</Offcanvas.Title>
      </Offcanvas.Header>
      <Offcanvas.Body className="h-screen flex flex-col justify-between">
        <div>
          {data.transaction.bankTransaction ? (
            <p>
              Bank Memo: {data?.transaction.bankTransaction?.name}
            </p>
          ) : null}

          <Form.Group className="mb-3">
            <Form.Label>Name</Form.Label>
            <Form.Control
              defaultValue={name}
              onChange={event => setName(event.target.value)} />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Amount</Form.Label>
            <Form.Control
              defaultValue={amount}
              onChange={event => setAmount(event.target.value)} />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Date</Form.Label>
            <Form.Control
              defaultValue={date}
              type="date"
              onChange={event => setDate(event.target.value)} />
          </Form.Group>

          <Form.Group className="mb-3">
            {allocations.length <= 1
              ? <BudgetSelect allocations={allocations} setAllocations={setAllocations} />
              : <MultiBudgetSelect allocations={allocations} setAllocations={setAllocations} />
            }
            <div className="flex justify-between relative">
              <button onClick={split}>Split</button>
              <TemplateSelect transaction={data.transaction} />
            </div>
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Label>Note</Form.Label>
            <Form.Control
              defaultValue={note}
              as="textarea"
              rows={3}
              onChange={event => setNote(event.target.value)} />
          </Form.Group>

          <Form.Group className="mb-3">
            <Form.Check
              type="checkbox"
              label="Reviewed"
              defaultChecked={reviewed}
              onClick={() => setReviewed(!reviewed)} />
          </Form.Group>
        </div>
        <div>
          <button className="w-full bg-sky-600 text-white font-bold text-lg hover:bg-gray-700 p-2" onClick={saveAndClose}>Save</button>
        </div>
      </Offcanvas.Body>
    </>
  )
}

const BudgetSelect = ({ allocations, setAllocations }: { allocations: BudgetAllocationInput[], setAllocations: Dispatch<SetStateAction<BudgetAllocationInput[]>> }) => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

  const setSpendFrom = (budgetId: string) => {
    setAllocations([
      {
        ...allocations[0],
        budget: { id: parseInt(budgetId) }
      }
    ])
  }

  return (
    <>
      <Form.Label>Spend From</Form.Label>
      <Form.Select value={allocations[0].budget.id} onChange={event => setSpendFrom(event.target.value)}>
        {data?.budgets.map(budget => (
          <option key={budget.id} value={budget.id}>
            {budget.name}
          </option>
        ))}
      </Form.Select>
    </>
  )
}

const TemplateSelect = ({ transaction }: { transaction: GetTransaction_transaction }) => {
  const { data } = useQuery<ListBudgetAllocationTemplates>(LIST_BUDGET_ALLOCATION_TEMPLATES)
  const [show, setShow] = useState(false)
  const [templateId, setTemplateId] = useState(data?.budgetAllocationTemplates[0].id)

  const allocations = data?.budgetAllocationTemplates
    .find(template => template.id === templateId)
    ?.budgetAllocationTemplateLines
    .map(line => ({
      amount: line.amount,
      budget: { id: parseInt(line.budget.id) }
    }))

  const [updateTransaction] = useMutation(UPDATE_TRANSACTION, {
    variables:
    {
      id: transaction.id,
      input: {
        budgetAllocations: allocations
      }
    }
  })

  const updateAndClose = () => {
    updateTransaction().then(() => {
      setShow(false)
    }).catch(error => {
      console.log(error)
    })
  }

  return (
    <>
      <button onClick={() => setShow(true)}>Apply Template</button>

      <Offcanvas show={show} onHide={() => setShow(false)} placement="end">
        <Offcanvas.Header closeButton>
          <Offcanvas.Title>Apply Template</Offcanvas.Title>
        </Offcanvas.Header>
        <Offcanvas.Body className="h-screen flex flex-col justify-between">
          <div>
            <Form.Group className="mb-2">
              <Form.Select onChange={event => setTemplateId(event.target.value)}>
                {data?.budgetAllocationTemplates.map(template => (
                  <option key={template.id} value={template.id}>
                    {template.name}
                  </option>
                ))}
              </Form.Select>
            </Form.Group>
          </div>
          <div>
            <button className="w-full bg-sky-600 text-white font-bold text-lg hover:bg-gray-700 p-2" onClick={updateAndClose}>Apply</button>
            <button className="w-full font-bold text-lg p-2" onClick={() => setShow(false)}>Cancel</button>
          </div>
        </Offcanvas.Body>
      </Offcanvas>
    </>
  )
}

const MultiBudgetSelect = ({ allocations, setAllocations }: { allocations: BudgetAllocationInput[], setAllocations: Dispatch<SetStateAction<BudgetAllocationInput[]>> }) => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

  const updateAllocationBudgetId = (value: string, atIndex: number) => {
    const newAllocations = allocations.map((allocation, index) => {
      if (index === atIndex) {
        return {
          ...allocation,
          budget: { id: parseInt(value) }
        }
      }

      return allocation
    })

    setAllocations(newAllocations)
  }

  const updateAllocationAmount = (value: string, atIndex: number) => {
    const newAllocations = allocations.map((allocation, index) => {
      if (index === atIndex) {
        return {
          ...allocation,
          amount: value
        }
      }

      return allocation
    })

    setAllocations(newAllocations)
  }

  const removeAllocation = (atIndex: number) => {
    const newAllocations = allocations.filter((_allocation, index) => index !== atIndex)
    setAllocations(newAllocations)
  }

  return (
    <>
      <div className="flex">
        <div className="w-2/3 mr-2">
          <Form.Label>Spend From</Form.Label>
        </div>
        <div className="w-1/3">
          <Form.Label>Amount</Form.Label>
        </div>
      </div>
      {allocations.map((allocation, index) => (
        <div key={index} className="flex mb-2">
          <div className="w-2/3 mr-2">
            <Form.Select value={allocation.budget.id} onChange={event => updateAllocationBudgetId(event.target.value, index)}>
              {data?.budgets.map(budget => <option key={budget.id} value={budget.id}>{budget.name}</option>)}
            </Form.Select>
          </div>
          <div className="w-1/3 flex items-center">
            <Form.Control
              value={allocation.amount}
              onChange={event => updateAllocationAmount(event.target.value, index)} />
            <FontAwesomeIcon icon={faCircleXmark} className="text-slate-500 ml-2" onClick={() => removeAllocation(index)} />
          </div>
        </div>
      ))}
    </>
  )
}

export default TransactionRow