# Portfolio 4 — NoSQL and Advanced Data Models

I used MongoDB collection transfer_events for transfer_initiated and transfer_posted events. These are fictional event examples based on transfer, account, ledger_entry.

## Document model

| Field | Meaning |
| --- | --- |
| _id | Unique string event ID |
| eventType | One of the two selected case event labels |
| occurredAt | Native BSON Date; sample timestamps are in 2030 |
| source | Original entity, primary key and saved JSON snapshot |
| embedded | Linked record snapshots read with the event |
| references | Keys for linked sources kept outside the embedded snapshots |
| details | Event metadata whose fields vary |

Related account details are stored as snapshots with the event. This makes an event readable in one document. It duplicates some information, and later SQL changes do not automatically update the snapshots. PostgreSQL continues to enforce the relational rules.

## Example document

```javascript
{
    "_id": "event_000001",
    "schemaVersion": 1,
    "simulation": true,
    "eventType": "transfer_initiated",
    "occurredAt": ISODate("2030-01-01T10:00:00Z"),
    "source": {
        "entity": "ledger_entry",
        "key": {
            "entry_id": 301
        },
        "snapshot": {
            "entry_id": 301,
            "transfer_id": 201,
            "account_id": 101,
            "amount": -25.5,
            "created_at": "2026-02-01T12:00:01Z"
        }
    },
    "embedded": {
        "account": [
            {
                "key": {
                    "account_id": 101
                },
                "snapshot": {
                    "account_id": 101,
                    "customer_id": 1,
                    "account_number": "ACCT-1001",
                    "currency": "USD",
                    "balance": 750.25
                },
                "via": [
                    "ledger_entry.account_id → account",
                    "ledger_entry.transfer_id → transfer.from_account_id → account"
                ]
            },
            {
                "key": {
                    "account_id": 102
                },
                "snapshot": {
                    "account_id": 102,
                    "customer_id": 2,
                    "account_number": "ACCT-1002",
                    "currency": "USD",
                    "balance": 500
                },
                "via": [
                    "ledger_entry.transfer_id → transfer.to_account_id → account"
                ]
            }
        ]
    },
    "references": {
        "transfer": [
            {
                "key": {
                    "transfer_id": 201
                },
                "via": [
                    "ledger_entry.transfer_id → transfer"
                ]
            }
        ]
    },
    "details": {
        "channel": "web"
    }
}
```

## Queries and results

| Query | Returned documents |
| --- | --- |
| Find the first sample event type (up to five documents). | 1 |
| Find events for the first source record using nested key fields (up to five). | 2 |
| Find events in the sample time range using a MongoDB Date filter (up to five). | 2 |
| Count documents for each event type. | 2 |

## 1. Find the first sample event type (up to five documents).

```javascript
db.getCollection("transfer_events").find({"eventType":"transfer_initiated"}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "transfer_initiated",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "entry_id": 301
    }
  }
]
```

## 2. Find events for the first source record using nested key fields (up to five).

```javascript
db.getCollection("transfer_events").find({"source.key.entry_id":301}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "transfer_initiated",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "entry_id": 301
    }
  },
  {
    "_id": "event_000002",
    "eventType": "transfer_posted",
    "occurredAt": {
      "$date": "2030-01-01T10:01:00Z"
    },
    "source": {
      "entry_id": 301
    }
  }
]
```

## 3. Find events in the sample time range using a MongoDB Date filter (up to five).

```javascript
db.getCollection("transfer_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray();
```

Selected fields from the returned documents:

```json
[
  {
    "_id": "event_000001",
    "eventType": "transfer_initiated",
    "occurredAt": {
      "$date": "2030-01-01T10:00:00Z"
    },
    "source": {
      "entry_id": 301
    }
  },
  {
    "_id": "event_000002",
    "eventType": "transfer_posted",
    "occurredAt": {
      "$date": "2030-01-01T10:01:00Z"
    },
    "source": {
      "entry_id": 301
    }
  }
]
```

## 4. Count documents for each event type.

```javascript
db.getCollection("transfer_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray();
```

| _id | documentCount |
| --- | --- |
| transfer_initiated | 1 |
| transfer_posted | 1 |

## Validation and suitability

MongoDB inserted 2 documents. An invalid date type was rejected with code 121 and a repeated event ID with 11000. The collection still contained 2 valid documents. The compound eventType/occurredAt index supports those access fields; this exercise does not measure its speed.

The details field can vary across event types, while the common fields have a validator. Events can be added as separate documents rather than growing one large history record.

## Run the script

Connect mongosh to a fresh exercise database and run Manu_Janet_301931640_P4_MongoDB.js. It selects portfolio_nosql, creates the collection, inserts the sample documents and displays the query results. [Implementation evidence](screenshots/Manu_Janet_301931640_P4_DocumentsAndQueries.png).

## References

- [MongoDB — data modelling](https://www.mongodb.com/docs/manual/data-modeling/)

