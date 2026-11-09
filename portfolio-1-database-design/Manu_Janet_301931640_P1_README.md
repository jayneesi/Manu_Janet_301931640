# Portfolio 1 — Database Design and Modelling

I organised the data into customer, account, transfer, ledger_entry. The design document explains the fields, keys, relationships and business rules. The normalisation document shows the sample tables at 1NF, 2NF and 3NF.

## Database checks

| Table | Rows |
| --- | --- |
| customer | 2 |
| account | 2 |
| transfer | 1 |
| ledger_entry | 1 |

The 36 invalid inserts were rejected at their expected constraints, and the valid sample rows remained unchanged.

## Files

- [Design](Manu_Janet_301931640_P1_Design.md)
- [ER diagram](Manu_Janet_301931640_P1_ERDiagram.md)
- [Normalisation](Manu_Janet_301931640_P1_Normalisation.md)
- [Schema](Manu_Janet_301931640_P1_Schema.sql)
- [Sample data](Manu_Janet_301931640_P1_SampleData.sql)
- [Constraint tests](Manu_Janet_301931640_P1_ConstraintTests.sql)
- [Table and constraint evidence](screenshots/Manu_Janet_301931640_P1_DatabaseResults.png)

## Run the SQL

Create a fresh PostgreSQL database. Run the schema first, then the sample data. Run the deliberately invalid statements in ConstraintTests.sql individually outside a transaction; each is expected to produce an error.

## References

- [PostgreSQL — constraints](https://www.postgresql.org/docs/17/ddl-constraints.html)

