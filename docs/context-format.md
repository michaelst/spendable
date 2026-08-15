# CONTEXT.md Format

Each context carries a `CONTEXT.md` next to its actions and schemas, defining the words that context
owns. It is a vocabulary, not a description of how the code works.

## Structure

```md
# Budgets

Envelopes the user divides their money into, and the rules that pre-fill them.

## Language

**Budget**:
A named envelope a user assigns money to.
_Avoid_: Category, bucket, envelope

**Allocation**:
A signed amount linking one Transaction to one Budget.
_Avoid_: Split, line, assignment

**Adjustment**:
A manual correction to a Budget's balance that no Transaction accounts for.
_Avoid_: Offset, correction

**Spendable**:
The reserved Budget that absorbs whatever a Transaction does not allocate elsewhere.
_Avoid_: Unallocated, remainder, default budget

## Relationships

- A **Budget** has many **Allocations**
- An **Allocation** belongs to exactly one **Budget** and one **Transaction**
- A **Budget**'s balance is derived from its **Allocations** plus its **Adjustment**

## Architecture decisions

- [ADR 0001](docs/adr/0001-spendable-absorbs-remainder.md) - Every Transaction is fully allocated; the remainder goes to Spendable.

## Example dialogue

> **Dev:** "If I allocate only part of a **Transaction** to a **Budget**, where does the rest go?"
> **Domain expert:** "Into **Spendable**. A **Transaction** is never partly unallocated."

## Flagged ambiguities

- "balance" was used to mean both a **Budget**'s derived balance and a **Bank Account**'s reported balance - resolved: these are distinct concepts and the second belongs to Banks.
```

## Sections

Only `## Language` is required, and the ones that appear come in exactly this order:

1. `## Language` - the terms, optionally grouped under `###` subheadings.
2. `## Relationships` - a flat bullet list of how the terms relate.
3. `## Architecture decisions` - one line per ADR under the context's `docs/adr/`, in number order. Present whenever the context has ADRs.
4. `## Example dialogue` - one or more Dev/Domain expert exchanges.
5. `## Flagged ambiguities` - a flat bullet list.

No other top-level sections. Content that wants one (boundaries, how to read the data) is a
**Language** term or a **Relationships** bullet instead.

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **`_Avoid_` lists wrong names, not wrong practices.** It names the words not to use for this term - aliases, colloquialisms, a neighbouring term it gets confused with - and at most a clause saying why. "Don't do X" is not vocabulary: cut it, or put it in the ADR. `_Avoid_: "Category"` belongs here; `_Avoid_: querying budgets without a user_id` does not.
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **Keep definitions tight.** One sentence max. Define what it IS, not what it does.
- **How the app works does not belong here.** Rationale, enforcement notes, edge cases, rejected alternatives and implementation detail are not vocabulary. Cut them; if the decision behind one is complex enough to be worth keeping, it becomes an ADR under the context's `docs/adr/` and gets a line in **Architecture decisions**.
- **Define each term once.** A second entry for the same term is a merge, not an addition. A term belongs to exactly one context - **Transaction** is defined in Transactions, and Budgets refers to it without redefining it.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Relationships are structural, not behavioral.** A bullet says how two terms relate - ownership, cardinality, what a value is derived from, which context owns which side. It never says what the app does, when it does it, or who is allowed to do it. "An **Allocation** belongs to one **Budget**" belongs here; "creating a Transaction allocates the remainder to Spendable" does not.
- **Only include terms specific to this project's context.** General programming concepts (timeouts, error types, scopes) don't belong even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs.
- **Group terms under subheadings** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is fine. Every term sits under `## Language`, never after `## Relationships`.

## Context map

`CONTEXT-MAP.md` at the repo root lists the contexts, where they live, and how they relate:

```md
# Context Map

## Contexts

- [Accounts](./lib/spendable/accounts/CONTEXT.md) - who the user is and how they sign in
- [Budgets](./lib/spendable/budgets/CONTEXT.md) - envelopes, allocations and the splits that pre-fill them
- [Transactions](./lib/spendable/transactions/CONTEXT.md) - the spending records a user reviews and allocates
- [Banks](./lib/spendable/banks/CONTEXT.md) - Plaid connections, accounts and the raw activity synced from them

## Relationships

- **Banks → Transactions**: a synced Bank Transaction produces one Transaction
- **Transactions → Budgets**: a Transaction's Allocations divide it across Budgets
- **Budgets → Banks**: a Budget may be backed by a Bank Account, which supplies its balance
- **Accounts → all**: every record in every context belongs to exactly one User
```
