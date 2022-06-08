import React, { Dispatch, SetStateAction, useState } from 'react'
import { useQuery } from '@apollo/client'
import { LIST_BUDGET_ALLOCATION_TEMPLATES } from '../queries'
import { Form, Offcanvas } from 'react-bootstrap'
import { ListBudgetAllocationTemplates } from '../graphql/ListBudgetAllocationTemplates'
import { BudgetAllocationInput } from './TransactionForm'
import Row from './Row'
import formatCurrency from '../utils/formatCurrency'
import TemplateForm from './TemplateForm'

type Props = {
  setAllocations: Dispatch<SetStateAction<BudgetAllocationInput[]>>
}

const TemplateSelect = ({ setAllocations }: Props) => {
  const [show, setShow] = useState(false)
  const [showNewTemplate, setShowNewTemplate] = useState(false)
  const [showEditTemplate, setShowEditTemplate] = useState(false)
  const [templateId, setTemplateId] = useState<string>()

  const { data } = useQuery<ListBudgetAllocationTemplates>(LIST_BUDGET_ALLOCATION_TEMPLATES, {
    onCompleted: data => setTemplateId(data.budgetAllocationTemplates[0].id)
  })

  const templateAllocations = data?.budgetAllocationTemplates
    .find(template => template.id === templateId)
    ?.budgetAllocationTemplateLines
    .map(line => ({
      amount: line.amount.toDecimalPlaces(2).toFixed(2),
      budget: { id: line.budget.id }
    })) ?? []

  const activeTemplate = data?.budgetAllocationTemplates.find(t => t.id === templateId)

  const updateAndClose = () => {
    setAllocations(templateAllocations)
    setShow(false)
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
              <Form.Select value={templateId} onChange={event => setTemplateId(event.target.value)}>
                {data?.budgetAllocationTemplates.map(template => (
                  <option key={template.id} value={template.id}>
                    {template.name}
                  </option>
                ))}
              </Form.Select>
            </Form.Group>

            <div className="flex flex-row justify-between mx-1">
              <div className="flex items-center">
                <button onClick={() => setShowNewTemplate(true)} className="text-right w-100 mb-4 text-sky-600">New Template</button>
                <TemplateForm show={showNewTemplate} setShow={setShowNewTemplate} />
              </div>
              <div className="flex items-center">
                <div className="flex flex-col items-end">
                  <button onClick={() => setShowEditTemplate(true)} className="text-right w-100 mb-4 text-sky-600">Edit Template</button>
                  <TemplateForm id={templateId} show={showEditTemplate} setShow={setShowEditTemplate} />
                </div>
              </div>
            </div>

            <div className="mx-1">
              <div className="mb-1 border-b">
                <Row leftSide="Budget" rightSide="Amount" />
              </div>
              {activeTemplate && [...activeTemplate.budgetAllocationTemplateLines].sort((a, b) => b.amount.comparedTo(a.amount)).map(line => (
                <div key={line.id} className="mb-1">
                  <Row leftSide={line.budget.name} rightSide={formatCurrency(line.amount)} />
                </div>
              ))}
            </div>
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

export default TemplateSelect