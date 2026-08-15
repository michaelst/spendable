# Delegating QA and demo recording to subagents

[qa](qa/SKILL.md) and [record-demo-video](record-demo-video/SKILL.md) are the two most expensive steps
in [complete-issue](complete-issue/SKILL.md): both read screenshot PNGs, both iterate (checks that need
a rewrite, three or four takes), and both produce a long transcript whose only lasting value is a
verdict. Run them inline and that transcript sits in the main context for the rest of the session —
through commit, PR, and review fixes.

So **dispatch each as its own subagent** and keep only its report.

## Dispatch

Use the Agent tool with `subagent_type: "general-purpose"` and **`run_in_background: false`** — the
workflow cannot continue until the verdict is in, and a foreground agent keeps the full toolset.

**Nesting is fine.** Agents may spawn agents up to five levels deep, so this works unchanged when the
parent skill is itself running in a subagent.

## The prompt has to carry the context

The subagent starts with nothing. Give it, explicitly:

- The **absolute repo path** and the branch, plus the base branch to diff against.
- The **requirements and the approved plan**, pasted in full — there is no ticket to fetch them from.
- **Two or three sentences on what changed** and the files touched, so it does not have to re-derive
  the change from scratch.
- The **scratchpad path** for checklists, scenarios, screenshots, and frames.
- The instruction to **invoke the skill** (`qa`, or `record-demo-video`) and follow it, including its
  data-hygiene rules — the dev database is the user's real budget, and never resets.
- The **return format** below.

## What must come back

Terse and structured. This report is the only evidence the parent has.

**QA**: the findings table (`# | Check | Result | Severity | Caused by this change? | Evidence`),
absolute paths to the screenshots behind any non-green row, the checks it could not run and why, and
the dev-data state it left behind.

**Demo**: the absolute mp4 path, the frames directory, one line on what the video shows, and the
`expect`/`refute` results.

## What the subagent must not do

- **Fix anything.** Blockers and majors go back to the parent, which owns the [tdd](tdd/SKILL.md) loop
  and re-running the gates from the top. A subagent fixing code mid-QA produces a diff the parent
  never reviewed.
- **Commit, push, or touch the PR.**
- **Stop the dev server** when a demo pass is next — it needs the same server up.

## What the parent owes in return

Do not re-run the checks or re-read the frames wholesale; that spends exactly what the delegation
saved. Read a cited screenshot or two when a finding looks wrong, and otherwise take the report as
given. Report to the user only what the subagent actually reported — never upgrade a thin report into
a clean pass.
