# Accounts

Who the user is and how they sign in. Every record in every other context belongs to one of them.

## Language

**User**:
A person with a Spendable account, identified by the Google account they sign in with.
_Avoid_: Customer, member, profile

**Bank Limit**:
How many bank connections a user is allowed to hold at once.
_Avoid_: Quota, plan, tier

**API Token**:
One signed-in device's credential. Held per device, so revoking one signs out only that device.
_Avoid_: Session, key

**Device Token**:
What APNs calls a device, held against the **API Token** it was registered with.
_Avoid_: Push token, APNs token outside the code that talks to Apple

**Notification**:
One push to a **User**, whatever produced it. A sync that found fifty charges is one of these.
_Avoid_: Alert, which is only its visible half, and message

## Relationships

- A **User** owns every **Budget**, **Transaction** and **Bank Member** in the system
- A **User**'s **Bank Limit** caps how many **Bank Members** they may hold
- A **User** holds one **API Token** per device, each carrying at most one **Device Token**
- A **Notification** goes to every **Device Token** a **User** has registered

## Flagged ambiguities

- "account" was used for both a Spendable login and a **Bank Account** - resolved: a login is a **User**, and "account" on its own always means the bank one.
