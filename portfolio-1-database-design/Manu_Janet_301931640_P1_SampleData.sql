-- Fictional sample records for Bank/Fintech Platform.
BEGIN;
SET LOCAL standard_conforming_strings = on;
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at") VALUES (1, 'Alex Morgan', 'alex.morgan@example.test', '2026-01-15T10:00:00Z');
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at") VALUES (2, 'Sam Lee', 'sam.lee@example.test', '2026-01-16T11:30:00+00:00');
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance") VALUES (101, 1, 'ACCT-1001', 'USD', 750.25);
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance") VALUES (102, 2, 'ACCT-1002', 'USD', 500);
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at") VALUES (201, 101, 102, 25.5, 'posted', 'idem-seed-201', '2026-02-01T12:00:00Z');
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at") VALUES (301, 201, 101, -25.5, '2026-02-01T12:00:01Z');
COMMIT;
