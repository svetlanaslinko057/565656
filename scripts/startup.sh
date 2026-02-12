#!/bin/bash
# =============================================================================
# FOMO Connections Module - Startup Script
# =============================================================================
# Запускается автоматически при развертывании
# 
# Что делает:
# 1. Ждёт MongoDB
# 2. Запускает полный seed (seed_all.sh)
# 3. Перезапускает сервисы
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONGO_DB="${DB_NAME:-connections_db}"

echo "=============================================="
echo "FOMO Startup - $(date)"
echo "=============================================="

# 1. Wait for MongoDB
echo "[Startup] Waiting for MongoDB..."
for i in {1..30}; do
  if mongosh --quiet --eval "db.runCommand('ping')" > /dev/null 2>&1; then
    echo "[Startup] MongoDB is ready"
    break
  fi
  echo "[Startup] Waiting for MongoDB... ($i/30)"
  sleep 1
done

# 2. Run seed script
echo "[Startup] Running seed script..."
if [ -f "$SCRIPT_DIR/seed_all.sh" ]; then
  chmod +x "$SCRIPT_DIR/seed_all.sh"
  "$SCRIPT_DIR/seed_all.sh"
else
  echo "[Startup] WARNING: seed_all.sh not found, running inline seed..."
  
  # Fallback inline seed for egress slots only
  mongosh $MONGO_DB --quiet --eval '
  db.twitter_egress_slots.updateOne(
    { label: "Parser Slot" },
    { $set: {
      label: "Parser Slot",
      type: "LOCAL_PARSER",
      enabled: true,
      localParser: { url: "http://localhost:5001" },
      health: { status: "HEALTHY" },
      limits: { requestsPerHour: 100 }
    }},
    { upsert: true }
  );
  db.proxy_slots.updateOne(
    { name: "direct-slot" },
    { $set: { name: "direct-slot", host: "DIRECT", port: 0, status: "ACTIVE", enabled: true, type: "DIRECT" }},
    { upsert: true }
  );
  print("Fallback seed complete");
  '
fi

# 3. Verify data
echo ""
echo "[Startup] Verifying seed data..."
mongosh $MONGO_DB --quiet --eval '
var profiles = db.connections_author_profiles.countDocuments();
var unified = db.connections_unified_accounts.countDocuments();
var taxonomy = db.connections_taxonomy_membership.countDocuments();

if (profiles < 10) {
  print("⚠️  WARNING: connections_author_profiles has only " + profiles + " records (expected 10+)");
} else {
  print("✅ connections_author_profiles: " + profiles);
}

if (unified < 10) {
  print("⚠️  WARNING: connections_unified_accounts has only " + unified + " records (expected 10+)");
} else {
  print("✅ connections_unified_accounts: " + unified);
}

if (taxonomy < 20) {
  print("⚠️  WARNING: connections_taxonomy_membership has only " + taxonomy + " records (expected 20+)");
} else {
  print("✅ connections_taxonomy_membership: " + taxonomy);
}
'

echo ""
echo "=============================================="
echo "STARTUP COMPLETE"
echo "=============================================="
echo ""
echo "Services:"
echo "  Frontend:  http://localhost:3000"
echo "  Backend:   http://localhost:8001"
echo "  Parser:    http://localhost:5001 (requires cookies)"
echo ""
echo "To restart services:"
echo "  sudo supervisorctl restart backend frontend"
echo ""
