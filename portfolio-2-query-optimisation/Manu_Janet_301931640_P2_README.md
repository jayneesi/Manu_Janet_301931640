# Bank/Fintech Platform — SQL queries

## 1. Show related customer, account records (up to 20).

```sql
SELECT t0."customer_id" AS "customer_customer_id",
       t0."full_name" AS "customer_full_name",
       t1."account_id" AS "account_account_id",
       t1."account_number" AS "account_account_number"
FROM portfolio."customer" t0
JOIN portfolio."account" t1 ON t1."customer_id" = t0."customer_id"
ORDER BY t0."customer_id", t1."account_id"
LIMIT 20;
```

| customer_customer_id | customer_full_name | account_account_id | account_account_number |
| --- | --- | --- | --- |
| 1 | Alex Morgan | 101 | ACCT-1001 |
| 2 | Sam Lee | 102 | ACCT-1002 |

## 2. Find transfer records where status matches "posted" (up to 20).

```sql
SELECT * FROM portfolio."transfer"
WHERE "status" IS NOT DISTINCT FROM 'posted'
ORDER BY "transfer_id"
LIMIT 20;
```

| transfer_id | from_account_id | to_account_id | amount | status | idempotency_key | created_at |
| --- | --- | --- | --- | --- | --- | --- |
| 201 | 101 | 102 | 25.5 | posted | idem-seed-201 | 2026-02-01T12:00:00+00:00 |

## 3. Count account records for each customer_id (up to 20 groups).

```sql
SELECT "customer_id", count(*) AS record_count
FROM portfolio."account"
GROUP BY "customer_id"
ORDER BY record_count DESC, "customer_id" NULLS LAST
LIMIT 20;
```

| customer_id | record_count |
| --- | --- |
| 1 | 1 |
| 2 | 1 |


## Index comparison

| Phase | Median (ms) | Three runs (ms) | Plan nodes | Buffer hits |
| --- | --- | --- | --- | --- |
| Before index | 2.603 | 2.639, 2.589, 2.603 | Sort → Seq Scan | 322 |
| After index | 0.344 | 0.44, 0.344, 0.298 | Sort → Bitmap Heap Scan → Bitmap Index Scan | 55 |

The median execution time changed from 2.603 ms to 0.344 ms. The measured plan used p2_filter_idx. The results matched in both phases. An index adds storage and write-maintenance costs; timings depend on the selected lookup and environment.

## Execution plans

### Before index, run 1

```text
Sort (actual time=2.605..2.608 rows=50 loops=1)
  Seq Scan on transfer (actual time=0.017..2.562 rows=50 loops=1)
Planning Time: 0.375 ms
Execution Time: 2.639 ms
```

### Before index, run 2

```text
Sort (actual time=2.556..2.559 rows=50 loops=1)
  Seq Scan on transfer (actual time=0.017..2.515 rows=50 loops=1)
Planning Time: 0.397 ms
Execution Time: 2.589 ms
```

### Before index, run 3

```text
Sort (actual time=2.57..2.572 rows=50 loops=1)
  Seq Scan on transfer (actual time=0.018..2.527 rows=50 loops=1)
Planning Time: 0.399 ms
Execution Time: 2.603 ms
```

### After index, run 1

```text
Sort (actual time=0.367..0.371 rows=50 loops=1)
  Bitmap Heap Scan on transfer (actual time=0.044..0.286 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.021..0.022 rows=50 loops=1)
Planning Time: 0.928 ms
Execution Time: 0.44 ms
```

### After index, run 2

```text
Sort (actual time=0.265..0.267 rows=50 loops=1)
  Bitmap Heap Scan on transfer (actual time=0.032..0.222 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.015..0.015 rows=50 loops=1)
Planning Time: 0.601 ms
Execution Time: 0.344 ms
```

### After index, run 3

```text
Sort (actual time=0.249..0.251 rows=50 loops=1)
  Bitmap Heap Scan on transfer (actual time=0.032..0.21 rows=50 loops=1)
    Bitmap Index Scan using p2_filter_idx (actual time=0.014..0.015 rows=50 loops=1)
Planning Time: 0.596 ms
Execution Time: 0.298 ms
```

## Reproduce

Use a fresh database with the Portfolio 1 schema and sample data. Run Manu_Janet_301931640_P2_Queries.sql, then Manu_Janet_301931640_P2_Optimisation.sql. The optimisation script creates a separate performance table and runs EXPLAIN (ANALYZE, BUFFERS).

[Query screenshot](screenshots/Manu_Janet_301931640_P2_QueryResults.png) · [Index comparison](screenshots/Manu_Janet_301931640_P2_IndexComparison.png)

## References

- [PostgreSQL — EXPLAIN](https://www.postgresql.org/docs/17/using-explain.html)

