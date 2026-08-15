# Accounts

Who the user is and how they sign in. Every record in every other context belongs to one of them.

## Language

**User**:
A person with a Spendable account, identified by the Google account they sign in with.
_Avoid_: Customer, member, profile

**Bank Limit**:
How many bank connections a user is allowed to hold at once.
_Avoid_: Quota, plan, tier

## Relationships

- A **User** owns every **Budget**, **Transaction** and **Bank Member** in the system
- A **User**'s **Bank Limit** caps how many **Bank Members** they may hold

## Flagged ambiguities

- "account" was used for both a Spendable login and a **Bank Account** - resolved: a login is a **User**, and "account" on its own always means the bank one.
