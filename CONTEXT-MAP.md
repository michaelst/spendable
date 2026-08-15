# Context Map

## Contexts

- [Accounts](./lib/spendable/accounts/CONTEXT.md) - who the user is and how they sign in
- [Budgets](./lib/spendable/budgets/CONTEXT.md) - the envelopes money is divided into, and the templates that pre-fill them
- [Transactions](./lib/spendable/transactions/CONTEXT.md) - the movements of money a user reviews and allocates
- [Banks](./lib/spendable/banks/CONTEXT.md) - Plaid connections, accounts, and the activity synced from them

## Relationships

- **Banks → Transactions**: a synced **Bank Transaction** produces one **Transaction**
- **Transactions → Budgets**: a **Transaction**'s **Allocations** divide it across **Budgets**, with the remainder in **Spendable**
- **Banks → Budgets**: a **Bank Account** assigned to a **Budget** supplies that budget's balance
- **Accounts → all**: every record in every context belongs to exactly one **User**, and that ownership is what authorizes every action
