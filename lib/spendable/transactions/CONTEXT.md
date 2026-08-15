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
Marks a **Transaction** the user has decided should not count toward spending, such as a reimbursed expense.
_Avoid_: Ignored, hidden, archived

**Transfer**:
A pair of **Transactions** moving the user's own money between the user's own accounts - one leaving, one arriving. Neither counts toward budgets. Both sides point at each other, so marking or removing one settles the other.
_Avoid_: Move, internal payment, self-payment

**Note**:
Free text the user adds to a **Transaction**, searched alongside its name.
_Avoid_: Memo, description, comment

## Relationships

- A **Transaction** has many **Allocations**, which divide it across **Budgets**
- A **Transaction** is always fully allocated; whatever is left over sits in **Spendable**
- A **Transaction** may have come from a **Bank Transaction**, or the user may have entered it themselves
- A settled **Transaction** inherits the **Allocations** of the pending one it replaces
- A **Transaction** may be one side of a **Transfer**, whose other side is another **Transaction**

## Example dialogue

> **Dev:** "A pending charge settles under a new id. Does the user have to allocate it again?"
> **Domain expert:** "No. It's the same purchase - the allocations move across with it."

> **Dev:** "What's the difference between **Excluded** and archiving?"
> **Domain expert:** "Excluded still happened, it just isn't spending. Nothing about a **Transaction** is archived; you delete it or you keep it."

> **Dev:** "Why is a **Transfer** two **Transactions** rather than one **Excluded** one?"
> **Domain expert:** "Because the bank gives you two - the money leaving one account and the same money arriving in the other. Pairing them says they're the same movement, and neither side is spending."

## Flagged ambiguities

- "transaction" was used for both this and the raw bank record - resolved: this one is a **Transaction**, the bank's is a **Bank Transaction**, and they are never the same row.
