import React, { Dispatch, SetStateAction, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { CREATE_TRANSACTION, DELETE_TRANSACTION, GET_TRANSACTION, LIST_BUDGETS, UPDATE_TRANSACTION } from '../queries'
import { DateTime } from 'luxon'
import { faCircleXmark } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { Button, Form, Modal, Offcanvas } from 'react-bootstrap'
import { GetTransaction } from '../graphql/GetTransaction'
import { ListBudgets } from '../graphql/ListBudgets'
import Decimal from 'decimal.js-light'
import TemplateSelect from './TemplateSelect'

type TransactionFormProps = {
  id?: string | null
  show: boolean
  setShow: Dispatch<SetStateAction<boolean>>
}

export type BudgetAllocationInput = {
  amount: string
  budget: {
    id: string
  }
}

type TransactionInput = {
  amount: string
  budgetAllocations: BudgetAllocationInput[]
  date: string
  name: string
  note?: string | null
  reviewed: boolean
}

const TransactionForm = ({ id, show, setShow }: TransactionFormProps) => {
  return id ?
    <UpdateTransactionForm id={id} show={show} setShow={setShow} />
    : <CreateTransactionForm show={show} setShow={setShow} />
}

const CreateTransactionForm = ({ show, setShow }: TransactionFormProps) => {
  const [createTransaction] = useMutation(CREATE_TRANSACTION)

  const saveAndClose = (input: TransactionInput) => {
    createTransaction({
      variables: {
        input: prepareInput(input)
      },
      refetchQueries: ['ListTransactions']
    })
      .then(() => {
        setShow(false)
      }).catch(error => {
        console.log(error)
      })
  }

  return (
    <Offcanvas show={show} onHide={() => setShow(false)} placement="end">
      <Offcanvas.Header closeButton>
        <Offcanvas.Title>Create Transaction</Offcanvas.Title>
      </Offcanvas.Header>
      <FormBody saveAndClose={saveAndClose} />
    </Offcanvas>
  )
}

const UpdateTransactionForm = ({ id, show, setShow }: TransactionFormProps) => {
  const [updateTransaction] = useMutation(UPDATE_TRANSACTION)

  const saveAndClose = (input: TransactionInput) => {
    updateTransaction({
      variables: {
        id: id,
        input: prepareInput(input)
      }
    })
      .then(() => {
        setShow(false)
      }).catch(error => {
        console.log(error)
      })
  }

  return (
    <Offcanvas show={show} onHide={() => setShow(false)} placement="end">
      <Offcanvas.Header closeButton>
        <Offcanvas.Title>Edit Transaction</Offcanvas.Title>
      </Offcanvas.Header>
      <FormBody id={id} saveAndClose={saveAndClose} />
    </Offcanvas>
  )
}

const prepareInput = (input: TransactionInput) => {
  return {
    ...input,
    budgetAllocations: input.budgetAllocations?.map(a => ({
      // if there is only a single allocation we should make sure to update the amount
      // to match the transaction amount before saving
      amount: input.budgetAllocations.length === 1 ? input.amount : a.amount,
      budget: { id: parseInt(a.budget.id) }
    }))
  }
}


const FormBody = ({ id, saveAndClose }: { id?: string | null, saveAndClose: (input: TransactionInput) => void }) => {
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
      setAllocations(data.transaction.budgetAllocations.map(a => ({ ...a, amount: a.amount.toDecimalPlaces(2).toFixed(2) })))
    }
  })


  if (!data && id) return null
  if (!budgets.data) return null

  const spendableId = budgets.data.budgets.find(b => b.name === "Spendable")!.id

  if (!id && allocations.length === 0) {
    setAllocations([{ amount: amount, budget: { id: spendableId } }])
  }

  const split = () => {
    const allocatedAmount = allocations.reduce((acc, allocation) => acc.plus(allocation.amount), new Decimal(0))

    const newAllocations = [
      ...allocations,
      {
        amount: new Decimal(amount).minus(allocatedAmount).toDecimalPlaces(2).toFixed(2),
        budget: { id: spendableId }
      }
    ]

    setAllocations(newAllocations)
  }

  return (
    <Offcanvas.Body className="h-screen flex flex-col justify-between">
      <div>
        {data?.transaction.bankTransaction && (
          <p>
            Bank Memo: {data?.transaction.bankTransaction?.name}
          </p>
        )}

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
            <TemplateSelect setAllocations={setAllocations} />
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
        <button className="w-full bg-sky-600 text-white font-bold text-lg hover:bg-gray-700 p-2" onClick={() => saveAndClose({
          amount: amount,
          date: date,
          name: name,
          note: note,
          reviewed: reviewed,
          budgetAllocations: allocations
        })}>Save</button>
        {id && <DeleteModal id={id} />}
      </div>
    </Offcanvas.Body>
  )
}

const DeleteModal = ({ id }: { id: string }) => {
  const [show, setShow] = useState(false)

  const [deleteTransaction] = useMutation(DELETE_TRANSACTION, {
    variables: { id: id },
    refetchQueries: ['ListTransactions']
  })

  return (
    <>
      <button className="w-full font-bold text-lg text-red-500 p-2" onClick={() => setShow(true)}>
        Delete
      </button>

      <Modal show={show} onHide={() => setShow(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Are you sure?</Modal.Title>
        </Modal.Header>
        <Modal.Body>Are you sure you want to delete this transaction?</Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShow(false)}>
            Cancel
          </Button>
          <Button variant="danger" onClick={() => deleteTransaction()}>
            Delete
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}

type AllocationSelectProps = {
  allocations: BudgetAllocationInput[]
  setAllocations: Dispatch<SetStateAction<BudgetAllocationInput[]>>
}

const BudgetSelect = ({ allocations, setAllocations }: AllocationSelectProps) => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

  const setSpendFrom = (budgetId: string) => {
    setAllocations([
      {
        ...allocations[0],
        budget: { id: budgetId }
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

const MultiBudgetSelect = ({ allocations, setAllocations }: AllocationSelectProps) => {
  const { data } = useQuery<ListBudgets>(LIST_BUDGETS)

  const updateAllocationBudgetId = (value: string, atIndex: number) => {
    const newAllocations = allocations.map((allocation, index) => {
      if (index === atIndex) {
        return {
          ...allocation,
          budget: { id: value }
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

export default TransactionForm