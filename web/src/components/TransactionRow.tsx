import React, { Dispatch, SetStateAction, useState } from 'react'
import { useLazyQuery, useMutation, useQuery } from '@apollo/client'
import { DELETE_TRANSACTION, GET_TRANSACTION, LIST_BUDGETS, MAIN_QUERY, UPDATE_TRANSACTION } from '../queries'
import { DateTime } from 'luxon'
import { faCheckCircle } from '@fortawesome/free-regular-svg-icons'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { DeleteTransaction } from '../graphql/DeleteTransaction'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import formatCurrency from '../utils/formatCurrency'
import { Form, Offcanvas } from 'react-bootstrap'
import { GetTransaction, GetTransaction_transaction } from '../graphql/GetTransaction'
import { ListBudgets } from '../graphql/ListBudgets'

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

          <Form>
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

            {allocations.length <= 1
              ? <BudgetSelect transaction={data.transaction} setSpendFrom={setSpendFrom} />
              : <MultiBudgetSelect />
            }

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
          </Form>
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
  data?.budgets.map(budget => console.log(budget.id, activeBudgetId, budget.id === activeBudgetId))

  return (
    <Form.Group className="mb-3">
      <Form.Label>Spend From</Form.Label>
      <Form.Select value={activeBudgetId} onChange={event => setSpendFrom(event.target.value)}>
        {data?.budgets.map(budget => (
          <option key={budget.id} value={budget.id}>
            {budget.name}
          </option>
        ))}
      </Form.Select>
    </Form.Group>
  )
}

const MultiBudgetSelect = () => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

  return (
    <>
      <Form.Group className="mb-3">
        <Form.Label>Spend From</Form.Label>
        <Form.Select>
          {data?.budgets.map(budget => <option value={budget.id}>{budget.name}</option>)}
        </Form.Select>
      </Form.Group>
      <Form.Group className="mb-3">
        <Form.Label>Amount</Form.Label>
        <Form.Control />
      </Form.Group>
    </>
  )
}

export default TransactionRow