# Bank/Fintech Platform — normalisation

The example uses the saved sample records. The full set of fields is in the design and schema.

## Starting grouped records

| customer_id | account records (list) |
| --- | --- |
| 1 | [101] |
| 2 | [102] |


The record IDs are grouped in a list. In 1NF, each record has its own row and each cell holds one value.

## 1NF: one value per cell

| account.account_id | account.customer_id | account.account_number | customer.customer_id | customer.full_name |
| --- | --- | --- | --- | --- |
| 101 | 1 | ACCT-1001 | 1 | Alex Morgan |
| 102 | 2 | ACCT-1002 | 2 | Sam Lee |

Key: account_id.

## 2NF: depend on the whole key

The declared candidate keys do not introduce a partial dependency here, so the 1NF rows stay unchanged at this step.

## account_example

| account.account_id | account.customer_id | account.account_number | customer.customer_id | customer.full_name |
| --- | --- | --- | --- | --- |
| 101 | 1 | ACCT-1001 | 1 | Alex Morgan |
| 102 | 2 | ACCT-1002 | 2 | Sam Lee |

## 3NF: store each entity’s details once

The entity keys determine their own descriptions. Related records keep foreign keys rather than repeating those descriptions.

## customer

| customer_id | full_name | email | created_at |
| --- | --- | --- | --- |
| 1 | Alex Morgan | alex.morgan@example.test | 2026-01-15T10:00:00+00:00 |
| 2 | Sam Lee | sam.lee@example.test | 2026-01-16T11:30:00+00:00 |

## account

| account_id | customer_id | account_number | currency | balance |
| --- | --- | --- | --- | --- |
| 101 | 1 | ACCT-1001 | USD | 750.25 |
| 102 | 2 | ACCT-1002 | USD | 500 |

## transfer

| transfer_id | from_account_id | to_account_id | amount | status | idempotency_key | created_at |
| --- | --- | --- | --- | --- | --- | --- |
| 201 | 101 | 102 | 25.5 | posted | idem-seed-201 | 2026-02-01T12:00:00+00:00 |

## ledger_entry

| entry_id | transfer_id | account_id | amount | created_at |
| --- | --- | --- | --- | --- |
| 301 | 201 | 101 | -25.5 | 2026-02-01T12:00:01+00:00 |

## Dependencies

- customer: (customer_id) → full_name, email, created_at
- account: (account_id) → customer_id, account_number, currency, balance
- transfer: (transfer_id) → from_account_id, to_account_id, amount, status, idempotency_key, created_at
- ledger_entry: (entry_id) → transfer_id, account_id, amount, created_at

Joining the decomposed sample tables reproduces the original 2 example rows. The design assumes the declared keys describe the relevant business dependencies.
