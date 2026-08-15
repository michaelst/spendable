// Worked example of one checklist item. Copy into the scratchpad, rewrite, run with
// `qa.sh run <file>`. Keep each file to one or two checklist rows so a failure names itself.
//
// Everything printed here ends up in the QA report, so print evidence (values, paths, problems),
// not narration.
const { openQaSession } = await import(process.env.QA_DRIVER)

const qa = await openQaSession({
  port: Number(process.env.QA_PORT),
  debugPort: Number(process.env.QA_DEBUG_PORT),
  scratchDir: process.env.QA_SCRATCH
})

const fail = (message) => {
  console.log(`FAIL ${message}`)
  process.exitCode = 1
}

// --- check: the budgets list renders and the new-budget form opens ---
await qa.goto('/budgets')

const budgets = await qa.evaluate(`document.querySelectorAll('#budgets li').length`)
console.log(`budgets: ${budgets}`)
if (budgets === 0) fail('no budgets: is this an empty state or a broken query?')

await qa.click(`document.querySelector('#new-budget')`)
// Visibility, not the `hidden` class: show_details() is a JS command that sets an inline display,
// so the class it was rendered with is still there on an open form.
const formOpen = await qa.evaluate(`!!document.querySelector('#details-form')?.checkVisibility()`)
if (!formOpen) fail('clicking New did not open the details form')

// Read the returned path with the Read tool. A screenshot catches what an assertion cannot:
// misalignment, an amount formatted as 1234.5 instead of $1,234.50, text clipped out of its column.
console.log(`shot: ${await qa.shot('budgets-new-form')}`)

// --- check: it survives a narrow viewport ---
await qa.resize(375, 812)
console.log(`shot: ${await qa.shot('budgets-mobile')}`)
const overflows = await qa.evaluate(`document.documentElement.scrollWidth > window.innerWidth + 2`)
if (overflows) fail('page scrolls horizontally at 375px')
await qa.resize(1280, 860)

// Always drain. A check that looks right and logs a 500 or a LiveView crash has still failed.
for (const problem of qa.drainProblems()) console.log(`PROBLEM ${problem.kind}: ${problem.detail}`)

await qa.finish()
