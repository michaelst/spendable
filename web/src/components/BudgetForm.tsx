import React, { Dispatch, SetStateAction, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import { CREATE_BUDGET, DELETE_BUDGET, GET_BUDGET_FOR_EDITING, LIST_BUDGETS, MAIN_QUERY, UPDATE_BUDGET } from '../queries'
import { Button, Form, Modal, Offcanvas } from 'react-bootstrap'
import { CreateBudgetInput, UpdateBudgetInput } from '../graphql/globalTypes'
import Decimal from 'decimal.js-light'
import { GetBudgetForEditing } from '../graphql/GetBudgetForEditing'
import { useNavigate } from 'react-router-dom'

type BudgetFormProps = {
  id?: string | null
  show: boolean
  setShow: Dispatch<SetStateAction<boolean>>
}

type BudgetInput = CreateBudgetInput | UpdateBudgetInput

const BudgetForm = ({ id, show, setShow }: BudgetFormProps) => {
  return id ?
    <UpdateBudgetForm id={id} show={show} setShow={setShow} />
    : <CreateBudgetForm show={show} setShow={setShow} />
}

const CreateBudgetForm = ({ show, setShow }: BudgetFormProps) => {
  const [createBudget] = useMutation(CREATE_BUDGET)

  const saveAndClose = (input: BudgetInput) => {
    createBudget({
      variables: {
        input: input
      },
      refetchQueries: [{ query: LIST_BUDGETS }, 'Main']
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
        <Offcanvas.Title>Create Budget</Offcanvas.Title>
      </Offcanvas.Header>
      <FormBody saveAndClose={saveAndClose} />
    </Offcanvas>
  )
}

const UpdateBudgetForm = ({ id, show, setShow }: BudgetFormProps) => {
  const [updateBudget] = useMutation(UPDATE_BUDGET)

  const saveAndClose = (input: BudgetInput) => {
    updateBudget({
      variables: {
        id: id,
        input: input
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
        <Offcanvas.Title>Edit Budget</Offcanvas.Title>
      </Offcanvas.Header>
      <FormBody id={id} saveAndClose={saveAndClose} />
    </Offcanvas>
  )
}

const FormBody = ({ id, saveAndClose }: { id?: string | null, saveAndClose: (input: BudgetInput) => void }) => {
  const [name, setName] = useState('')
  const [trackSpendingOnly, setTrackSpendingOnly] = useState(false)
  const [balance, setBalance] = useState('0')
  const zero = new Decimal(0)

  const { data } = useQuery<GetBudgetForEditing>(GET_BUDGET_FOR_EDITING, {
    variables: { id: id },
    onCompleted: data => {
      setName(data.budget.name)
      setTrackSpendingOnly(data.budget.trackSpendingOnly)
      setBalance(data.budget.balance.toDecimalPlaces(2).toFixed(2))
    },
    skip: !id
  })

  if (!data && id) return null

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
          <Form.Label>Balance</Form.Label>
          <Form.Control
            value={balance}
            onChange={event => setBalance(event.target.value)} />
        </Form.Group>

        <Form.Group className="mb-3">
          <div className="flex justify-between">
            <Form.Label>Track Spending Only</Form.Label>
            <Form.Check
              checked={trackSpendingOnly}
              onChange={e => setTrackSpendingOnly(e.currentTarget.checked)}
              type="switch"
            />
          </div>
        </Form.Group>
      </div>
      <div>
        <button className="w-full bg-sky-600 text-white font-bold text-lg hover:bg-gray-700 p-2" onClick={() => saveAndClose({
          name: name,
          trackSpendingOnly: trackSpendingOnly,
          adjustment: new Decimal(balance).minus(data?.budget.balance ?? zero).add(data?.budget.adjustment ?? zero)
        })}>Save</button>
        {id && <DeleteModal id={id} />}
      </div>
    </Offcanvas.Body>
  )
}

const DeleteModal = ({ id }: { id: string }) => {
  const [show, setShow] = useState(false)
  const navigate = useNavigate()

  const [deleteBudget] = useMutation(DELETE_BUDGET, {
    variables: { id: id },
    refetchQueries: [{ query: LIST_BUDGETS }, { query: MAIN_QUERY }]
  })

  const onConfirm = () => {
    deleteBudget()
      .then(() => {
        setShow(false)
        navigate("/")
      })
  }

  return (
    <>
      <button className="w-full font-bold text-lg text-red-500 p-2" onClick={() => setShow(true)}>
        Delete
      </button>

      <Modal show={show} onHide={() => setShow(false)}>
        <Modal.Header closeButton>
          <Modal.Title>Are you sure?</Modal.Title>
        </Modal.Header>
        <Modal.Body>Are you sure you want to delete this budget?</Modal.Body>
        <Modal.Footer>
          <Button variant="secondary" onClick={() => setShow(false)}>
            Cancel
          </Button>
          <Button variant="danger" onClick={onConfirm}>
            Delete
          </Button>
        </Modal.Footer>
      </Modal>
    </>
  )
}

export default BudgetForm