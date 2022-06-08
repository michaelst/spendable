import React, { Dispatch, SetStateAction, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { CREATE_BUDGET_ALLOCATION_TEMPLATE, DELETE_BUDGET_ALLOCATION_TEMPLATE, GET_BUDGET_ALLOCATION_TEMPLATE, LIST_BUDGETS, LIST_BUDGET_ALLOCATION_TEMPLATES, UPDATE_BUDGET_ALLOCATION_TEMPLATE } from '../queries'
import { faCircleXmark } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { Button, Form, Modal, Offcanvas } from 'react-bootstrap'
import { ListBudgets } from '../graphql/ListBudgets'
import TemplateSelect from './TemplateSelect'
import { GetBudgetAllocationTemplate } from '../graphql/GetBudgetAllocationTemplate'
import { CreateBudgetAllocationBudgetInput, UpdateBudgetAllocationTemplateInput } from '../graphql/globalTypes'
import Decimal from 'decimal.js-light'

type TemplateFormProps = {
  id?: string | null
  show: boolean
  setShow: Dispatch<SetStateAction<boolean>>
}

export type LineInput = {
  amount: string
  budget: {
    id: string
  }
}

type TemplateInput = {
  budgetAllocationTemplateLines: LineInput[]
  name: string
}

const TemplateForm = ({ id, show, setShow }: TemplateFormProps) => {
  return id ?
    <UpdateTemplateForm id={id} show={show} setShow={setShow} />
    : <CreateTemplateForm show={show} setShow={setShow} />
}

const CreateTemplateForm = ({ show, setShow }: TemplateFormProps) => {
  const [createTemplate] = useMutation(CREATE_BUDGET_ALLOCATION_TEMPLATE)

  const saveAndClose = (input: TemplateInput) => {
    createTemplate({
      variables: {
        input: prepareInput(input)
      },
      refetchQueries: [{ query: LIST_BUDGET_ALLOCATION_TEMPLATES }]
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
        <Offcanvas.Title>Create Template</Offcanvas.Title>
      </Offcanvas.Header>
      <FormBody saveAndClose={saveAndClose} />
    </Offcanvas>
  )
}

const UpdateTemplateForm = ({ id, show, setShow }: TemplateFormProps) => {
  const [updateTemplate] = useMutation(UPDATE_BUDGET_ALLOCATION_TEMPLATE)

  const saveAndClose = (input: TemplateInput) => {
    updateTemplate({
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
        <Offcanvas.Title>Edit Template</Offcanvas.Title>
      </Offcanvas.Header>
      <FormBody id={id} saveAndClose={saveAndClose} />
    </Offcanvas>
  )
}

const prepareInput = (input: TemplateInput): CreateBudgetAllocationBudgetInput | UpdateBudgetAllocationTemplateInput => {
  return {
    ...input,
    budgetAllocationTemplateLines: input.budgetAllocationTemplateLines?.map(a => ({
      amount: new Decimal(a.amount),
      budget: { id: parseInt(a.budget.id) }
    }))
  }
}


const FormBody = ({ id, saveAndClose }: { id?: string | null, saveAndClose: (input: TemplateInput) => void }) => {
  const [name, setName] = useState('')
  const [allocations, setAllocations] = useState<LineInput[]>([])

  const budgets = useQuery<ListBudgets>(LIST_BUDGETS)

  const { data } = useQuery<GetBudgetAllocationTemplate>(GET_BUDGET_ALLOCATION_TEMPLATE, {
    variables: { id: id },
    onCompleted: data => {
      setName(data.budgetAllocationTemplate.name ?? '')
      setAllocations(data.budgetAllocationTemplate.budgetAllocationTemplateLines.map(l => ({ ...l, amount: l.amount.toDecimalPlaces(2).toFixed(2) })))
    }
  })


  if (!data && id) return null
  if (!budgets.data) return null

  const spendableId = budgets.data.budgets.find(b => b.name === "Spendable")!.id

  if (!id && allocations.length === 0) {
    setAllocations([{ amount: '0', budget: { id: spendableId } }])
  }

  const split = () => {
    const newAllocations = [
      ...allocations,
      {
        amount: '0',
        budget: { id: spendableId }
      }
    ]

    setAllocations(newAllocations)
  }

  return (
    <Offcanvas.Body className="h-screen flex flex-col justify-between">
      <div>
        <Form.Group className="mb-3">
          <Form.Label>Name</Form.Label>
          <Form.Control
            defaultValue={name}
            onChange={event => setName(event.target.value)} />
        </Form.Group>

        <Form.Group className="mb-3">
          <MultiBudgetSelect allocations={allocations} setAllocations={setAllocations} />
          <div className="flex justify-between relative">
            <button onClick={split}>Split</button>
          </div>
        </Form.Group>
      </div>
      <div>
        <button className="w-full bg-sky-600 text-white font-bold text-lg hover:bg-gray-700 p-2" onClick={() => saveAndClose({
          name: name,
          budgetAllocationTemplateLines: allocations
        })}>Save</button>
        {id && <DeleteModal id={id} />}
      </div>
    </Offcanvas.Body>
  )
}

const DeleteModal = ({ id }: { id: string }) => {
  const [show, setShow] = useState(false)

  const [deleteTemplate] = useMutation(DELETE_BUDGET_ALLOCATION_TEMPLATE, {
    variables: { id: id },
    refetchQueries: [{ query: LIST_BUDGET_ALLOCATION_TEMPLATES }]
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
        <Modal.Body>Are you sure you want to delete this template?</Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShow(false)}>
            Cancel
          </Button>
          <Button variant="danger" onClick={() => deleteTemplate()}>
            Delete
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}

type AllocationSelectProps = {
  allocations: LineInput[]
  setAllocations: Dispatch<SetStateAction<LineInput[]>>
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

export default TemplateForm