-- Run these deliberately invalid statements one at a time, outside a transaction.
-- Each should fail at the named constraint; the sample rows should remain unchanged.

-- 1. pk customer duplicate. Expected: pk_customer, SQLSTATE 23505.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at")
VALUES (1, 'Taylor Quinn', 'taylor.quinn@example.test', '2026-03-01T09:00:00Z');

-- 2. uq customer email duplicate. Expected: uq_customer_0, SQLSTATE 23505.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at")
VALUES (1001, 'Taylor Quinn', 'alex.morgan@example.test', '2026-03-01T09:01:00Z');

-- 3. nn customer id. Expected: customer_id, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at")
VALUES (NULL, 'Taylor Quinn', 'taylor.id@example.test', '2026-03-01T09:02:00Z');

-- 4. nn customer name. Expected: full_name, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at")
VALUES (1002, NULL, 'taylor.name@example.test', '2026-03-01T09:03:00Z');

-- 5. nn customer email. Expected: email, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at")
VALUES (1003, 'Taylor Quinn', NULL, '2026-03-01T09:04:00Z');

-- 6. nn customer created. Expected: created_at, SQLSTATE 23502.
INSERT INTO portfolio."customer" ("customer_id", "full_name", "email", "created_at")
VALUES (1004, 'Taylor Quinn', 'taylor.created@example.test', NULL);

-- 7. pk account duplicate. Expected: pk_account, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (101, 1, 'ACCT-9001', 'USD', 10);

-- 8. uq account number duplicate. Expected: uq_account_0, SQLSTATE 23505.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1101, 1, 'ACCT-1001', 'EUR', 10);

-- 9. fk account customer missing. Expected: fk_account_0, SQLSTATE 23503.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1102, 9001, 'ACCT-9002', 'USD', 10);

-- 10. nn account id. Expected: account_id, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (NULL, 1, 'ACCT-9003', 'USD', 10);

-- 11. nn account customer. Expected: customer_id, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1103, NULL, 'ACCT-9004', 'USD', 10);

-- 12. nn account number. Expected: account_number, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1104, 1, NULL, 'USD', 10);

-- 13. nn account currency. Expected: currency, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1105, 1, 'ACCT-9005', NULL, 10);

-- 14. nn account balance. Expected: balance, SQLSTATE 23502.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1106, 1, 'ACCT-9006', 'USD', NULL);

-- 15. check account balance negative. Expected: account_nonnegative_balance, SQLSTATE 23514.
INSERT INTO portfolio."account" ("account_id", "customer_id", "account_number", "currency", "balance")
VALUES (1107, 1, 'ACCT-9007', 'USD', -0.01);

-- 16. pk transfer duplicate. Expected: pk_transfer, SQLSTATE 23505.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (201, 101, 102, 3, 'posted', 'idem-test-pk-2101', '2026-03-02T10:00:00Z');

-- 17. uq transfer idempotency duplicate. Expected: uq_transfer_0, SQLSTATE 23505.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2101, 101, 102, 3, 'posted', 'idem-seed-201', '2026-03-02T10:01:00Z');

-- 18. fk transfer source missing. Expected: fk_transfer_0, SQLSTATE 23503.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2102, 9002, 102, 3, 'posted', 'idem-test-fk-2102', '2026-03-02T10:02:00Z');

-- 19. fk transfer destination missing. Expected: fk_transfer_1, SQLSTATE 23503.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2103, 101, 9003, 3, 'posted', 'idem-test-fk-2103', '2026-03-02T10:03:00Z');

-- 20. nn transfer id. Expected: transfer_id, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (NULL, 101, 102, 3, 'posted', 'idem-test-nn-2104', '2026-03-02T10:04:00Z');

-- 21. nn transfer source. Expected: from_account_id, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2105, NULL, 102, 3, 'posted', 'idem-test-nn-2105', '2026-03-02T10:05:00Z');

-- 22. nn transfer destination. Expected: to_account_id, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2106, 101, NULL, 3, 'posted', 'idem-test-nn-2106', '2026-03-02T10:06:00Z');

-- 23. nn transfer amount. Expected: amount, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2107, 101, 102, NULL, 'posted', 'idem-test-nn-2107', '2026-03-02T10:07:00Z');

-- 24. nn transfer status. Expected: status, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2108, 101, 102, 3, NULL, 'idem-test-nn-2108', '2026-03-02T10:08:00Z');

-- 25. nn transfer idempotency. Expected: idempotency_key, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2109, 101, 102, 3, 'posted', NULL, '2026-03-02T10:09:00Z');

-- 26. nn transfer created. Expected: created_at, SQLSTATE 23502.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2110, 101, 102, 3, 'posted', 'idem-test-nn-2110', NULL);

-- 27. check transfer amount nonpositive. Expected: transfer_positive_amount, SQLSTATE 23514.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2111, 101, 102, 0, 'posted', 'idem-test-check-2111', '2026-03-02T10:11:00Z');

-- 28. check transfer same account. Expected: transfer_distinct_accounts, SQLSTATE 23514.
INSERT INTO portfolio."transfer" ("transfer_id", "from_account_id", "to_account_id", "amount", "status", "idempotency_key", "created_at")
VALUES (2112, 101, 101, 3, 'posted', 'idem-test-check-2112', '2026-03-02T10:12:00Z');

-- 29. pk ledger duplicate. Expected: pk_ledger_entry, SQLSTATE 23505.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (301, 201, 101, 1, '2026-03-03T08:00:00Z');

-- 30. fk ledger transfer missing. Expected: fk_ledger_entry_0, SQLSTATE 23503.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (3101, 9004, 101, 1, '2026-03-03T08:01:00Z');

-- 31. fk ledger account missing. Expected: fk_ledger_entry_1, SQLSTATE 23503.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (3102, 201, 9005, 1, '2026-03-03T08:02:00Z');

-- 32. nn ledger entry id. Expected: entry_id, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (NULL, 201, 101, 1, '2026-03-03T08:03:00Z');

-- 33. nn ledger transfer. Expected: transfer_id, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (3103, NULL, 101, 1, '2026-03-03T08:04:00Z');

-- 34. nn ledger account. Expected: account_id, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (3104, 201, NULL, 1, '2026-03-03T08:05:00Z');

-- 35. nn ledger amount. Expected: amount, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (3105, 201, 101, NULL, '2026-03-03T08:06:00Z');

-- 36. nn ledger created. Expected: created_at, SQLSTATE 23502.
INSERT INTO portfolio."ledger_entry" ("entry_id", "transfer_id", "account_id", "amount", "created_at")
VALUES (3106, 201, 101, 1, NULL);
