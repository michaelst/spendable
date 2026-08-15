# Budgets

The envelopes a user divides their money into, and the rules that pre-fill them.

## Language

### Budgets

**Budget**:
A named envelope a user assigns money to.
_Avoid_: Category, bucket, envelope

**Budget Type**:
Whether a **Budget** reserves money, saves toward an amount, or only records spending.
_Avoid_: Kind, mode

**Envelope**:
A **Budget** that reserves money for a purpose.

**Goal**:
A **Budget** saving toward a target amount.

**Tracking**:
A **Budget** that records spending without reserving anything against it.
_Avoid_: Track-only, spending-only

**Balance**:
What a **Budget** currently holds. Never stored - see **Relationships** for what it comes from.
_Avoid_: Total, amount

**Budgeted Amount**:
What the user intends a **Budget** to hold, against which its **Balance** is read.
_Avoid_: Target, limit, cap

**Adjustment**:
The correction that makes a **Budget**'s **Balance** the figure the user asked for.
_Avoid_: Offset, manual entry

**Spendable**:
The reserved tracking **Budget** that holds whatever a **Transaction** does not allocate elsewhere.
_Avoid_: Unallocated, remainder, default budget

**Archiving**:
Retiring a **Budget** or **Template** so it stops appearing, without erasing what it explains.
_Avoid_: Deleting, hiding

### Allocations and templates

**Allocation**:
A signed amount tying one **Transaction** to one **Budget**.
_Avoid_: Split, assignment, entry

**Template**:
A named set of **Lines** used to pre-fill a **Transaction**'s **Allocations**.
_Avoid_: Rule, preset, recipe

**Line**:
One **Budget** and amount on a **Template**.
_Avoid_: Row, item, template allocation

## Relationships

- A **Budget** has many **Allocations**
- An **Allocation** belongs to exactly one **Budget** and one **Transaction**
- A **Budget**'s **Balance** is the sum of its **Allocations** plus its **Adjustment**, unless a **Bank Account** is assigned to it, in which case the **Balance** is that account's
- A **Template** has many **Lines**; a **Line** names one **Budget**
- A **User** has at most one **Spendable** budget, created the first time one is needed
- Spending is read per month and is derived from **Allocations**, so it belongs to a month rather than to a **Budget**

## Example dialogue

> **Dev:** "If I allocate only part of a **Transaction** to a **Budget**, where does the rest go?"
> **Domain expert:** "**Spendable**. A **Transaction** is never left partly unallocated - the rest is money you haven't decided about yet."

> **Dev:** "So what does editing a **Budget**'s **Balance** actually write?"
> **Domain expert:** "The **Adjustment**. You're telling it what the balance ought to be, and the adjustment is the difference."

## Flagged ambiguities

- "balance" meant both a **Budget**'s derived balance and a **Bank Account**'s reported one - resolved: they are distinct, and the second belongs to Banks.
- "template" was used for both a **Template** and a HEEx template - resolved: in domain terms it is only ever the former.
