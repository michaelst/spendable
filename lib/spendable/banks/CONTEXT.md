# Banks

Connections to financial institutions, and the activity that comes from them.

## Language

**Bank Member**:
One connection to one institution, holding the token that keeps it alive.
_Avoid_: Connection, institution, item, link

**Provider**:
Who a **Bank Member**'s activity comes from - Plaid, or FinanceKit.
_Avoid_: Source, integration

**Bank Account**:
A single account held at a **Bank Member** - a checking account, a credit card.
_Avoid_: Account on its own, which means a Spendable login

**Bank Transaction**:
Activity exactly as the bank reported it, kept as the record of what was synced.
_Avoid_: Transaction, which is the user-facing one

**Sync**:
Pulling a **Bank Member**'s current state from Plaid: the connection, its accounts, and their activity.
_Avoid_: Refresh, import, fetch

**Syncing**:
Whether a **Bank Account**'s activity is pulled at all. A user may connect an account and still not want it.
_Avoid_: Enabled, active

**Pending**:
A **Bank Transaction** the bank has not settled, and will later settle.
_Avoid_: Unconfirmed, provisional

**History Token**:
An opaque marker of where the device's last read of Wallet left off.
_Avoid_: Cursor, checkpoint

**Link Token**:
A short-lived token that lets Plaid Link open, either for a new **Bank Member** or to repair an existing one.
_Avoid_: Access token, public token

**Status**:
What Plaid last said about a **Bank Member**'s health, or CONNECTED when it said nothing.
_Avoid_: State, health

## Relationships

- A **Bank Member** has many **Bank Accounts**
- A **Bank Account** has many **Bank Transactions**
- A **Bank Transaction** produces one **Transaction**, which is the one the user works with
- A **Bank Account** may be assigned to a **Budget**, and then supplies that budget's balance
- A **User**'s **Bank Limit** caps how many Plaid **Bank Members** they may hold

## Example dialogue

> **Dev:** "The user connects a bank. When do they see their transactions?"
> **Domain expert:** "Not immediately - the first **Sync** pulls months of history, so it runs on the queue and the accounts appear when it finishes."

> **Dev:** "What happens when a login expires?"
> **Domain expert:** "Plaid returns no accounts rather than an error. There's nothing to sync until they reconnect, and they reconnect with a **Link Token** against the existing **Bank Member**."

## Flagged ambiguities

- "balance" on a **Bank Account** is what the bank reports, not a **Budget**'s derived balance - resolved: they are separate concepts owned by separate contexts.
- Plaid calls a connection an "item" - resolved: we call it a **Bank Member**, and "item" appears only at the client boundary.
- FinanceKit names account kinds its own way - resolved: a **Bank Account**'s `type` and `sub_type` keep the Plaid vocabulary whatever the **Provider**, so there is one name for each kind of account.
