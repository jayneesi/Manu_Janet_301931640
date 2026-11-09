# Bank/Fintech Platform — ER diagram

```mermaid
erDiagram
    direction LR
    customer {
        bigint customer_id PK
        text full_name
        text email UK
        timestamptz created_at
    }
    account {
        bigint account_id PK
        bigint customer_id FK
        text account_number UK
        text currency
        numeric balance
    }
    transfer {
        bigint transfer_id PK
        bigint from_account_id FK
        bigint to_account_id FK
        numeric amount
        text status
        text idempotency_key UK
        timestamptz created_at
    }
    ledger_entry {
        bigint entry_id PK
        bigint transfer_id FK
        bigint account_id FK
        numeric amount
        timestamptz created_at
    }
    customer ||--o{ account : "customer_id"
    account ||--o{ transfer : "from_account_id"
    account ||--o{ transfer : "to_account_id"
    transfer ||--o{ ledger_entry : "transfer_id"
    account ||--o{ ledger_entry : "account_id"
```

PK identifies a record; FK links to another table; UK marks a single-field unique value. The relationship ends show exactly one, zero or one, or zero or many records. Composite unique keys and conditional rules are listed in the schema and design.

[Diagram image](../images/Manu_Janet_301931640_ERDiagram.png)
