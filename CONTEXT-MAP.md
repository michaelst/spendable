# Context Map

## Contexts

- [Accounts](./lib/spendable/accounts/CONTEXT.md) - who the user is and how they sign in
- [Budgets](./lib/spendable/budgets/CONTEXT.md) - the envelopes money is divided into, and the splits that pre-fill them
- [Transactions](./lib/spendable/transactions/CONTEXT.md) - the movements of money a user reviews and allocates
- [Banks](./lib/spendable/banks/CONTEXT.md) - Plaid connections, accounts, and the activity synced from them
- [OAuth](./lib/spendable/oauth/CONTEXT.md) - how an outside app is allowed to act as a user, and for how long

## Relationships

- **Banks → Transactions**: a synced **Bank Transaction** produces one **Transaction**
- **Transactions → Budgets**: a **Transaction**'s **Allocations** divide it across **Budgets**, with the remainder in **Spendable**
- **Banks → Budgets**: a **Bank Account** assigned to a **Budget** supplies that budget's balance
- **Accounts → OAuth**: a **User** grants an **Authorization**, and every token issued under it acts as that user
- **OAuth → all**: an **Access Token** admits an outside app to the MCP tools, which reach the other contexts only through their public API, as the token's **User**
- **Accounts → all**: every record in every context belongs to exactly one **User**, and that ownership is what authorizes every action
