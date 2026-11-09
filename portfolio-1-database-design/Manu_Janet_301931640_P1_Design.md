# Bank/Fintech Platform — database design

My case study records customer, account, transfer, ledger_entry.

## Users

- Customers reviewing account activity
- Operations staff investigating transfers

## Main operations

- Create and maintain customer accounts
- Record transfers between accounts
- Review transfer history and account activity

## Entities

| Entity | Information stored |
| --- | --- |
| customer | Stores a person or business that owns accounts. |
| account | Stores an account, its owner, currency, and current balance. |
| transfer | Records a transfer's source, destination, amount, status, idempotency key, and creation time. |
| ledger_entry | Records a transfer's signed account-level balance movement. |

## customer

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| customer_id | BIGINT | PK | Yes |
| full_name | TEXT |  | Yes |
| email | TEXT | Unique | Yes |
| created_at | TIMESTAMPTZ |  | Yes |
- Unique key: (email).

## account

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| account_id | BIGINT | PK | Yes |
| customer_id | BIGINT | FK | Yes |
| account_number | TEXT | Unique | Yes |
| currency | TEXT |  | Yes |
| balance | NUMERIC(18,2) |  | Yes |
- customer_id → customer.customer_id
- Unique key: (account_number).

## transfer

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| transfer_id | BIGINT | PK | Yes |
| from_account_id | BIGINT | FK | Yes |
| to_account_id | BIGINT | FK | Yes |
| amount | NUMERIC(18,2) |  | Yes |
| status | TEXT |  | Yes |
| idempotency_key | TEXT | Unique | Yes |
| created_at | TIMESTAMPTZ |  | Yes |
- from_account_id → account.account_id
- to_account_id → account.account_id
- Unique key: (idempotency_key).

## ledger_entry

| Field | Type | Key | Required |
| --- | --- | --- | --- |
| entry_id | BIGINT | PK | Yes |
| transfer_id | BIGINT | FK | Yes |
| account_id | BIGINT | FK | Yes |
| amount | NUMERIC(18,2) |  | Yes |
| created_at | TIMESTAMPTZ |  | Yes |
- transfer_id → transfer.transfer_id
- account_id → account.account_id

## Relationships and business rules

- Each customer email identifies at most one customer.
- Every account must reference an existing customer.
- Each account number identifies at most one account.
- An account balance cannot be below zero.
- Every transfer source account must exist.
- Every transfer destination account must exist.
- A transfer amount must be greater than zero.
- A transfer source and destination must be different accounts.
- An idempotency key identifies at most one transfer, preventing duplicate transfers from concurrent repeated requests.
- Every ledger entry must reference an existing transfer.
- Every ledger entry must reference an existing account.

## Assumptions

- All records use synthetic data; each entity has a globally unique single-column identifier.
- Each account belongs to one customer; each transfer has distinct source and destination accounts.
- A transfer, its balance changes, and its ledger entries are committed atomically.
- For normalisation, account is the root entity: customer_id determines customer details, so customer details are stored once in customer and referenced by account.customer_id.
- Each transfer has an idempotency key; concurrent requests with the same key must not create duplicate transfers.
- The separate benchmark uses 50,000 synthetic transfers and compares filtering by status before and after a B-tree index; no timing outcome is assumed.

