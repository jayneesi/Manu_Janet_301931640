// Run once in mongosh against a fresh exercise database.
// These records are fictional events for the case study.
(async function () {
  db = db.getSiblingDB('portfolio_nosql');
  if ((await db.getCollectionNames()).includes("transfer_events")) {
    throw new Error('The exercise collection already exists. Use a fresh database.');
  }

  // The validator checks the stable event fields while details can vary.
  await db.createCollection("transfer_events", {
    validator: {
    "$jsonSchema": {
        "bsonType": "object",
        "required": [
            "_id",
            "schemaVersion",
            "simulation",
            "eventType",
            "occurredAt",
            "source",
            "embedded",
            "references",
            "details"
        ],
        "properties": {
            "_id": {
                "bsonType": "string",
                "minLength": 1
            },
            "schemaVersion": {
                "enum": [
                    1
                ]
            },
            "simulation": {
                "enum": [
                    true
                ]
            },
            "eventType": {
                "bsonType": "string",
                "enum": [
                    "transfer_initiated",
                    "transfer_posted"
                ]
            },
            "occurredAt": {
                "bsonType": "date"
            },
            "source": {
                "bsonType": "object",
                "required": [
                    "entity",
                    "key",
                    "snapshot"
                ],
                "properties": {
                    "entity": {
                        "enum": [
                            "ledger_entry"
                        ]
                    },
                    "key": {
                        "bsonType": "object",
                        "required": [
                            "entry_id"
                        ]
                    },
                    "snapshot": {
                        "bsonType": "object"
                    }
                }
            },
            "embedded": {
                "bsonType": "object"
            },
            "references": {
                "bsonType": "object"
            },
            "details": {
                "bsonType": "object"
            }
        }
    }
},
    validationLevel: 'strict', validationAction: 'error'
  });

  // Insert the four example events and show their IDs.
  printjson(await db.getCollection("transfer_events").insertMany([
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
    },
    {
        "_id": "event_000002",
        "schemaVersion": 1,
        "simulation": true,
        "eventType": "transfer_posted",
        "occurredAt": ISODate("2030-01-01T10:01:00Z"),
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
            "channel": "mobile",
            "note": "Illustrative event-specific metadata",
            "examples": {
                "channel": "illustrative channel",
                "metadata": "illustrative metadata",
                "risk_signals": "illustrative risk_signals"
            }
        }
    }
]));
  await db.getCollection("transfer_events").createIndex({eventType: 1, occurredAt: -1}, {name: 'event_type_time'});

  // 1. Find the first sample event type (up to five documents).
  printjson(await db.getCollection("transfer_events").find({"eventType":"transfer_initiated"}).sort({_id:1}).limit(5).toArray());

  // 2. Find events for the first source record using nested key fields (up to five).
  printjson(await db.getCollection("transfer_events").find({"source.key.entry_id":301}).sort({_id:1}).limit(5).toArray());

  // 3. Find events in the sample time range using a MongoDB Date filter (up to five).
  printjson(await db.getCollection("transfer_events").find({"occurredAt":{"$gte":ISODate("2030-01-01T10:00:00Z"), "$lt":ISODate("2030-01-01T11:00:00Z")}}).sort({_id:1}).limit(5).toArray());

  // 4. Count documents for each event type.
  printjson(await db.getCollection("transfer_events").aggregate([{"$group":{"_id":"$eventType", "documentCount":{"$sum":1}}}, {"$sort":{"_id":1}}]).toArray());

  // A date stored as text should be rejected by the validator.
  try {
    await db.getCollection("transfer_events").insertOne({...{
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
}, _id: 'invalid_date_example', occurredAt: 'not-a-date'});
  } catch (error) { print('Invalid date error: ' + error.code); }

  // Reusing an event ID should be rejected by the unique _id index.
  try { await db.getCollection("transfer_events").insertOne({
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
}); }
  catch (error) { print('Duplicate ID error: ' + error.code); }

  print('Document count: ' + await db.getCollection("transfer_events").countDocuments());
})().catch(error => { print(error.stack || String(error)); quit(1); });
