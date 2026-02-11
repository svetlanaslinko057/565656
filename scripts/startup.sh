#!/bin/bash
# Startup script for Connections Module

echo "[Startup] Initializing database..."

# Wait for MongoDB to be ready
for i in {1..30}; do
    if mongosh --quiet --eval "db.runCommand('ping').ok" 2>/dev/null; then
        echo "[Startup] MongoDB is ready"
        break
    fi
    echo "[Startup] Waiting for MongoDB... ($i/30)"
    sleep 1
done

# Create database and seed slots
mongosh connections_db --quiet --eval '
// Create twitter_egress_slots collection with index
db.twitter_egress_slots.createIndex({ "label": 1 }, { unique: true, sparse: true });

// Insert parser slot if not exists
if (db.twitter_egress_slots.countDocuments({ label: "Parser Slot" }) === 0) {
    db.twitter_egress_slots.insertOne({
        label: "Parser Slot",
        type: "LOCAL_PARSER",
        enabled: true,
        localParser: { url: "http://localhost:5001" },
        health: { status: "HEALTHY" },
        limits: { requestsPerHour: 100 },
        createdAt: new Date(),
        updatedAt: new Date()
    });
    print("Created Parser Slot");
} else {
    print("Parser Slot already exists");
}

// Create proxy_slots collection with index
db.proxy_slots.createIndex({ "name": 1 }, { unique: true, sparse: true });

// Insert direct proxy slot if not exists
if (db.proxy_slots.countDocuments({ name: "direct-slot" }) === 0) {
    db.proxy_slots.insertOne({
        name: "direct-slot",
        host: "DIRECT",
        port: 0,
        status: "ACTIVE",
        enabled: true,
        type: "DIRECT",
        createdAt: new Date(),
        updatedAt: new Date()
    });
    print("Created direct proxy slot");
} else {
    print("Direct proxy slot already exists");
}

print("Database initialization complete");
'

echo "[Startup] Database initialization complete"
