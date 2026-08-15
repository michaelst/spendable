# Transactions

The individual movements of money a user reviews and divides between budgets.

## Language

**Transaction**:
One movement of money, negative when it leaves the user and positive when it arrives.
_Avoid_: Payment, charge, entry, activity

**Reviewed**:
Marks that the user has looked at a **Transaction** and is done with it.
_Avoid_: Approved, confirmed, cleared

**Excluded**:
Marks a **Transaction** that should not count toward spending, such as a transfer between the user's own accounts.
_Avoid_: Ignored, hidden, archived

**Note**:
Free text the user adds to a **Transaction**, searched alongside its name.
_Avoid_: Memo, description, comment

## Relationships

- A **Transaction** has many **Allocations**, which divide it across **Budgets**
- A **Transaction** is always fully allocated; whatever is left over sits in **Spendable**
- A **Transaction** may have come from a **Bank Transaction**, or the user may have entered it themselves
- A settled **Transaction** inherits the **Allocations** of the pending one it replaces

## Example dialogue

> **Dev:** "A pending charge settles under a new id. Does the user have to allocate it again?"
> **Domain expert:** "No. It's the same purchase - the allocations move across with it."

> **Dev:** "What's the difference between **Excluded** and archiving?"
> **Domain expert:** "Excluded still happened, it just isn't spending - a transfer between your own accounts. Nothing about a **Transaction** is archived; you delete it or you keep it."

## Flagged ambiguities

- "transaction" was used for both this and the raw bank record - resolved: this one is a **Transaction**, the bank's is a **Bank Transaction**, and they are never the same row.
