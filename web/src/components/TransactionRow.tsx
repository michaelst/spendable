import React, { Dispatch, SetStateAction, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { DELETE_TRANSACTION, GET_TRANSACTION, LIST_BUDGETS, LIST_BUDGET_ALLOCATION_TEMPLATES, MAIN_QUERY, UPDATE_TRANSACTION } from '../queries'
import { DateTime } from 'luxon'
import { faCheckCircle } from '@fortawesome/free-regular-svg-icons'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { DeleteTransaction } from '../graphql/DeleteTransaction'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'
import { Form, Offcanvas } from 'react-bootstrap'
import { GetTransaction, GetTransaction_transaction, GetTransaction_transaction_budgetAllocations } from '../graphql/GetTransaction'
import { ListBudgets } from '../graphql/ListBudgets'
import { ListBudgetAllocationTemplates } from '../graphql/ListBudgetAllocationTemplates'

export type TransactionRowItem = {
  id: string
  name: string | null
  amount: Decimal
  date: Date
  reviewed: boolean
  hideDelete?: boolean
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

  const { data } = useQuery<GetTransaction>(GET_TRANSACTION, {
    variables: { id: id },
    onCompleted: data => {
      setName(data.transaction.name ?? '')
      setAmount(data.transaction.amount.toDecimalPlaces(2).toFixed(2))
      setDate(DateTime.fromJSDate(data.transaction.date).toISODate())
      setNote(data.transaction.note ?? '')
      setReviewed(data.transaction.reviewed)
    }
  })

  const [updateTransaction] = useMutation(UPDATE_TRANSACTION)

  if (!data) return null

  const allocations = data.transaction.budgetAllocations

  const spendFromValue = allocations.map(a => a.budget.name).join(', ')

  const setSpendFrom = (budgetId: string) => {
    updateTransaction({
      variables: {
        id: id,
        input: {
          budgetAllocations: [{
            amount: amount,
            budget: { id: parseInt(budgetId) }
          }]
        }
      }
    })
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
          reviewed: reviewed
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
              ? <BudgetSelect transaction={data.transaction} setSpendFrom={setSpendFrom} />
              : <MultiBudgetSelect allocations={allocations} />
            }
            <div className="flex justify-between relative">
              <button>Split</button>
              <TemplateSelect transaction={data.transaction} setSpendFrom={setSpendFrom} />
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

const BudgetSelect = ({ transaction, setSpendFrom }: { transaction: GetTransaction_transaction, setSpendFrom: (budgetId: string) => void }) => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)
  const activeBudgetId = transaction.budgetAllocations[0].budget.id

  return (
    <>
      <Form.Label>Spend From</Form.Label>
      <Form.Select value={activeBudgetId} onChange={event => setSpendFrom(event.target.value)}>
        {data?.budgets.map(budget => (
          <option key={budget.id} value={budget.id}>
            {budget.name}
          </option>
        ))}
      </Form.Select>
    </>
  )
}

const TemplateSelect = ({ transaction, setSpendFrom }: { transaction: GetTransaction_transaction, setSpendFrom: (budgetId: string) => void }) => {
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

const MultiBudgetSelect = ({ allocations }: { allocations: GetTransaction_transaction_budgetAllocations[] }) => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

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
      {allocations.map(allocation => (
        <div key={allocation.id} className="flex mb-2">
          <div className="w-2/3 mr-2">
            <Form.Select value={allocation.budget.id} onChange={() => null}>
              {data?.budgets.map(budget => <option key={budget.id} value={budget.id}>{budget.name}</option>)}
            </Form.Select>
          </div>
          <div className="w-1/3">
            <Form.Control defaultValue={allocation.amount.toDecimalPlaces(2).toFixed(2)} />
          </div>
        </div>
      ))}
    </>
  )
}

export default TransactionRow