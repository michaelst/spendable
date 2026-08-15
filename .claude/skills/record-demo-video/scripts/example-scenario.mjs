// Worked example: creating an envelope budget on /budgets. Copy this into the scratchpad and
// rewrite the steps for the feature being demonstrated.
//
// Run through record.sh, which supplies the env vars and encodes the result. The driver is imported
// by the path record.sh injects, so a scenario works from wherever it is saved.
const { openSession } = await import(process.env.DEMO_DRIVER)

const demo = await openSession({
  frameDir: process.env.DEMO_FRAME_DIR,
  port: Number(process.env.DEMO_PORT),
  debugPort: Number(process.env.DEMO_DEBUG_PORT)
})

// Authenticate and get to the starting screen before recording, so the video opens on the feature.
await demo.login({ name: process.env.DEMO_COOKIE_NAME, value: process.env.DEMO_COOKIE_VALUE })
await demo.goto('/budgets', 4000)

demo.startCapture()

const form = `document.querySelector('#details-form')`
const nameInput = `${form} input[name="budget[name]"]`
const typeSelect = `${form} select[name="budget[type]"]`
const amountInput = `${form} input[name="budget[budgeted_amount]"]`

await demo.step('The budgets list, showing each envelope and what it holds this month', 2600)
await demo.step('Add a new one', 1600)
await demo.click(`document.querySelector('#new-budget')`)
await demo.wait(1200)
// Visibility, not the `hidden` class: show_details() sets an inline display, so the class it was
// rendered with is still there on an open form.
await demo.expect(`!!${form}?.checkVisibility()`, 'the details form to open')

await demo.step('Name it, and make it an Envelope so it reserves money', 1800)
await demo.click(nameInput)
await demo.type('Car Maintenance')
await demo.wait(600)

// A select is a change event, not a click - set the value and let LiveView see it.
await demo.evaluate(`
  (() => {
    const select = ${typeSelect}
    select.value = 'envelope'
    select.dispatchEvent(new Event('change', { bubbles: true }))
  })()
`)
await demo.wait(1400)
await demo.expect(`!!${amountInput}`, 'the budgeted amount field to appear for an envelope')

await demo.step('Envelope budgets ask what they should hold. Tracking budgets do not.', 2400)
await demo.click(amountInput)
await demo.type('120')
await demo.wait(1200)

await demo.step('Save it', 1400)
await demo.click(`[...${form}.querySelectorAll('button')].find(b => b.textContent.includes('Save'))`)
await demo.wait(2600)

await demo.expect(
  `document.body.innerText.includes('Car Maintenance')`,
  'the new budget in the list'
)
await demo.step('It is in the list, ready to be allocated against.', 2800)

console.log(`FRAMES ${await demo.finish()}`)
