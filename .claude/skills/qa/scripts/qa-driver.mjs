// The recording driver plus the things a QA pass needs and a demo does not: everything the browser
// complained about while you were clicking, and screenshots on demand instead of on a timer.
//
// Trusted input events matter even more here than in a demo - a synthetic `element.click()` that
// silently no-ops looks exactly like a feature that silently no-ops, so the whole pass would be
// unfalsifiable. Hence CDP, not the in-app Browser pane.
import { mkdirSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { fileURLToPath } from 'node:url'

const driverPath = fileURLToPath(new URL('../../record-demo-video/scripts/driver.mjs', import.meta.url))

export async function openQaSession({ port, debugPort, scratchDir }) {
  const { openSession } = await import(driverPath)

  mkdirSync(scratchDir, { recursive: true })
  const session = await openSession({
    frameDir: join(scratchDir, 'frames'),
    port,
    debugPort
  })

  // Collected rather than thrown: a QA pass wants the whole list at the end of a flow, not to abort
  // on the first warning. Drain them per check so each one is attributed to the step that caused it.
  const problems = []
  const note = (kind, detail) => problems.push({ kind, detail })

  session.on('Runtime.consoleAPICalled', ({ type, args }) => {
    if (type !== 'error' && type !== 'warning') return
    note(`console.${type}`, args.map((a) => a.value ?? a.description ?? a.type).join(' '))
  })
  session.on('Runtime.exceptionThrown', ({ exceptionDetails }) =>
    note('uncaught exception', exceptionDetails.exception?.description ?? exceptionDetails.text)
  )
  session.on('Log.entryAdded', ({ entry }) => {
    if (entry.level !== 'error' && entry.level !== 'warning') return
    note(`browser ${entry.level}`, `${entry.text} ${entry.url ?? ''}`.trim())
  })
  session.on('Network.responseReceived', ({ response }) => {
    if (response.status < 400) return
    note(`http ${response.status}`, response.url)
  })
  // A LiveView that crashes server-side drops the socket and reconnects, which is invisible in a
  // screenshot but is always a bug worth reporting.
  session.on('Network.webSocketClosed', ({ requestId }) => note('liveview socket closed', requestId))

  await session.send('Log.enable')
  await session.send('Network.enable')

  let shots = 0

  return Object.assign(session, {
    // Everything the browser complained about since the last drain, so a check that comes back
    // clean visually can still fail on what it logged.
    drainProblems() {
      return problems.splice(0, problems.length)
    },

    // Read the returned path with the Read tool: PNGs render, and this is how layout bugs, wrong
    // number formatting, and clipped text get caught. Tests cannot see any of them.
    async shot(name) {
      const { data } = await session.send('Page.captureScreenshot', { format: 'png' })
      const path = join(scratchDir, `${String(++shots).padStart(2, '0')}-${name}.png`)
      writeFileSync(path, Buffer.from(data, 'base64'))
      return path
    },

    // The visible text of the page, for asserting copy and for spotting a raw error or a stray
    // `nil` that a screenshot makes easy to skim past.
    text: () => session.evaluate(`document.body.innerText`),

    // Narrow viewport check without relaunching Chrome. Reset with resize(1280, 860).
    async resize(width, height) {
      await session.send('Emulation.setDeviceMetricsOverride', {
        width,
        height,
        deviceScaleFactor: 1,
        mobile: width < 768
      })
      await session.wait(400)
    }
  })
}
