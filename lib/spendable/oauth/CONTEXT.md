# OAuth

How an outside app is allowed to act as a user, and for how long.

## Language

### Apps and consent

**Client**:
An outside app that acts as a **User**, identified either by registering here or by a URL that
serves its own metadata.
_Avoid_: App, integration, connection

**Registration**:
A **Client** telling Spendable its name and **Redirect URI**s, and being given a **Client** id back.
_Avoid_: Signup, install

**Client Metadata Document**:
A JSON document at an https URL that a **Client** uses as its id, standing in for **Registration**.
_Avoid_: Manifest, well-known document

**Consent**:
The user's approval, on Spendable's own screen, of one **Client** acting as them.
_Avoid_: Grant, permission, authorization (a granted request is an **Authorization**)

**Redirect URI**:
The address a **Client** is sent back to with its **Authorization Code**, registered in advance so a
code cannot be handed to anyone else.
_Avoid_: Callback URL, return URL

**Authorization**:
The standing ability of one **Client** to act as one **User**, which the user can end at any time.
_Avoid_: Session, grant, connection

### Tokens

**Authorization Code**:
The single-use, short-lived proof of **Consent** a **Client** trades for tokens.
_Avoid_: Auth code, grant code

**Code Challenge**:
The hash a **Client** publishes when it asks, and whose secret it must produce when it trades the
**Authorization Code** in.
_Avoid_: PKCE (that is the protocol, not the value), nonce

**Access Token**:
The short-lived token a **Client** presents to act as a **User**, bound to the **MCP Resource**.
_Avoid_: API key, bearer (bearer is how it is sent)

**Refresh Token**:
The longer-lived token a **Client** trades for a new **Access Token**, spent and replaced on every
use.
_Avoid_: Renewal token

**Token Family**:
Every token descended from one **Consent**, revoked together the moment a spent **Refresh Token**
comes back.
_Avoid_: Chain, lineage, session

**Client Secret**:
The value a **Client** that keeps secrets proves itself with, in place of a **Code Challenge**.
_Avoid_: Password, API key

**MCP Resource**:
The address an **Access Token** is good for, and the only one it can be spent at.
_Avoid_: Audience, scope (the scope is the separate `mcp` string)

## Relationships

- A **User** has many **Authorization**s; each is one **User** and one **Client**
- A **Client** is identified either by its **Registration** or by its **Client Metadata Document**
- A **Client** has one or more registered **Redirect URI**s
- **Consent** produces one **Authorization Code**, which produces one **Access Token** and one
  **Refresh Token**
- Every **Access Token** and **Refresh Token** belongs to one **Token Family** and one **User**
- A **Refresh Token** points at the one that replaced it
- An **Access Token** carries the **MCP Resource** it is good for
- A **Client Secret** exists only for a **Client** whose **Registration** asked for one

## Flagged ambiguities

- "scope" meant both the OAuth `mcp` string a token carries and `Spendable.Scope`, the caller every
  action takes - resolved: the OAuth one is only ever spelled out as the token's scope, and
  **Scope** on its own remains the caller.
- "client" was also loose talk for the MCP client program - resolved: the program is whatever it
  calls itself (Claude, an editor); a **Client** is the registered identity it authorizes as.
