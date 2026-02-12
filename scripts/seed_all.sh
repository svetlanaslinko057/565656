#!/bin/bash
# =============================================================================
# FOMO Connections Module - Complete Seed Script
# =============================================================================
# Запускать при каждом развертывании для инициализации данных
# 
# Использование: ./scripts/seed_all.sh
# =============================================================================

set -e

echo "=============================================="
echo "FOMO Seed Script - Initializing Database"
echo "=============================================="

MONGO_DB="${DB_NAME:-connections_db}"

echo "[1/6] Creating indexes and egress slots..."
mongosh $MONGO_DB --quiet --eval '
// Egress slot для парсера
db.twitter_egress_slots.updateOne(
  { label: "Parser Slot" },
  { $set: {
    label: "Parser Slot",
    type: "LOCAL_PARSER",
    enabled: true,
    localParser: { url: "http://localhost:5001" },
    health: { status: "HEALTHY" },
    limits: { requestsPerHour: 100 },
    createdAt: new Date(),
    updatedAt: new Date()
  }},
  { upsert: true }
);

// Proxy slot (DIRECT = без прокси)
db.proxy_slots.updateOne(
  { name: "direct-slot" },
  { $set: {
    name: "direct-slot",
    host: "DIRECT",
    port: 0,
    status: "ACTIVE",
    enabled: true,
    type: "DIRECT"
  }},
  { upsert: true }
);

print("✅ Egress slots created");
'

echo "[2/6] Seeding connections_author_profiles (main page)..."
mongosh $MONGO_DB --quiet --eval '
const profiles = [
  { author_id: "a16z", username: "a16z", name: "a16z", avatar: "https://pbs.twimg.com/profile_images/1/a16z.jpg", followers: 1200000, following: 245, profile: "whale", verified: true, 
    scores: { influence_score: 950, x_score: 420, signal_noise: 8.2, risk_level: "low" },
    activity: { posts_count: 45, window_days: 30, avg_likes: 1200, total_likes: 54000 },
    trend: { velocity_norm: 0.15, acceleration_norm: 0.05 },
    categories: ["VC"] },
  { author_id: "paradigm", username: "paradigm", name: "Paradigm", followers: 450000, following: 189, profile: "whale", verified: true,
    scores: { influence_score: 920, x_score: 380, signal_noise: 7.8, risk_level: "low" },
    activity: { posts_count: 32, window_days: 30, avg_likes: 850 },
    categories: ["VC"] },
  { author_id: "vitalikbuterin", username: "vitalikbuterin", name: "Vitalik Buterin", followers: 5200000, following: 389, profile: "whale", verified: true,
    scores: { influence_score: 990, x_score: 520, signal_noise: 9.1, risk_level: "low" },
    activity: { posts_count: 28, window_days: 30, avg_likes: 45000 },
    categories: ["FOUNDER"] },
  { author_id: "cobie", username: "cobie", name: "Cobie", followers: 890000, following: 456, profile: "influencer", verified: true,
    scores: { influence_score: 880, x_score: 460, signal_noise: 7.5, risk_level: "low" },
    activity: { posts_count: 67, window_days: 30, avg_likes: 3200 },
    categories: ["KOL"] },
  { author_id: "hsaka", username: "hsaka", name: "Hsaka", followers: 220000, following: 312, profile: "influencer", verified: false,
    scores: { influence_score: 750, x_score: 320, signal_noise: 6.8, risk_level: "medium" },
    activity: { posts_count: 89, window_days: 30, avg_likes: 890 },
    categories: ["KOL"] },
  { author_id: "pentoshi", username: "pentoshi", name: "Pentoshi", followers: 680000, following: 289, profile: "influencer", verified: true,
    scores: { influence_score: 720, x_score: 340, signal_noise: 6.2, risk_level: "medium" },
    activity: { posts_count: 112, window_days: 30, avg_likes: 1450 },
    categories: ["KOL"] },
  { author_id: "raoulpal", username: "raoulpal", name: "Raoul Pal", followers: 1100000, following: 567, profile: "whale", verified: true,
    scores: { influence_score: 850, x_score: 390, signal_noise: 7.2, risk_level: "low" },
    activity: { posts_count: 52, window_days: 30, avg_likes: 2800 },
    categories: ["KOL"] },
  { author_id: "lookonchain", username: "lookonchain", name: "Lookonchain", followers: 780000, following: 123, profile: "influencer", verified: true,
    scores: { influence_score: 780, x_score: 410, signal_noise: 8.5, risk_level: "low" },
    activity: { posts_count: 145, window_days: 30, avg_likes: 2100 },
    categories: ["ANALYST"] },
  { author_id: "cz_binance", username: "cz_binance", name: "CZ", followers: 8900000, following: 245, profile: "whale", verified: true,
    scores: { influence_score: 980, x_score: 550, signal_noise: 8.8, risk_level: "low" },
    activity: { posts_count: 34, window_days: 30, avg_likes: 85000 },
    categories: ["FOUNDER"] },
  { author_id: "brian_armstrong", username: "brian_armstrong", name: "Brian Armstrong", followers: 1500000, following: 156, profile: "whale", verified: true,
    scores: { influence_score: 900, x_score: 380, signal_noise: 7.6, risk_level: "low" },
    activity: { posts_count: 22, window_days: 30, avg_likes: 12000 },
    categories: ["FOUNDER"] },
];

profiles.forEach(p => {
  db.connections_author_profiles.updateOne(
    { author_id: p.author_id },
    { $set: { ...p, createdAt: new Date(), updatedAt: new Date() } },
    { upsert: true }
  );
});

print("✅ Seeded " + profiles.length + " author profiles");
'

echo "[3/6] Seeding connections_unified_accounts..."
mongosh $MONGO_DB --quiet --eval '
const accounts = [
  { handle: "a16z", title: "a16z", kind: "TWITTER", smart: 0.92, influence: 0.95, early: 0.75, authority: 0.90, followers: 1200000, following: 245, categories: ["VC"], tags: ["crypto", "web3"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.9, lastSeen: new Date() },
  { handle: "paradigm", title: "Paradigm", kind: "TWITTER", smart: 0.91, influence: 0.92, early: 0.78, authority: 0.88, followers: 450000, following: 189, categories: ["VC"], tags: ["crypto", "defi"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.9, lastSeen: new Date() },
  { handle: "vitalikbuterin", title: "Vitalik Buterin", kind: "TWITTER", smart: 0.98, influence: 0.99, early: 0.85, authority: 0.95, followers: 5200000, following: 389, categories: ["FOUNDER"], tags: ["ethereum", "crypto"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.95, lastSeen: new Date() },
  { handle: "cobie", title: "Cobie", kind: "TWITTER", smart: 0.88, influence: 0.88, early: 0.82, authority: 0.75, followers: 890000, following: 456, categories: ["KOL"], tags: ["trading", "crypto"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.85, lastSeen: new Date() },
  { handle: "hsaka", title: "Hsaka", kind: "TWITTER", smart: 0.82, influence: 0.75, early: 0.85, authority: 0.65, followers: 220000, following: 312, categories: ["KOL"], tags: ["trading", "alpha"], source: "PLAYWRIGHT_PARSER", verified: false, confidence: 0.7, lastSeen: new Date() },
  { handle: "pentoshi", title: "Pentoshi", kind: "TWITTER", smart: 0.79, influence: 0.72, early: 0.78, authority: 0.60, followers: 680000, following: 289, categories: ["KOL"], tags: ["trading"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.7, lastSeen: new Date() },
  { handle: "raoulpal", title: "Raoul Pal", kind: "TWITTER", smart: 0.86, influence: 0.85, early: 0.70, authority: 0.78, followers: 1100000, following: 567, categories: ["KOL"], tags: ["macro", "crypto"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.85, lastSeen: new Date() },
  { handle: "lookonchain", title: "Lookonchain", kind: "TWITTER", smart: 0.85, influence: 0.78, early: 0.92, authority: 0.72, followers: 780000, following: 123, categories: ["ANALYST"], tags: ["onchain", "alpha"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.85, lastSeen: new Date() },
  { handle: "cz_binance", title: "CZ", kind: "TWITTER", smart: 0.88, influence: 0.98, early: 0.60, authority: 0.92, followers: 8900000, following: 245, categories: ["FOUNDER"], tags: ["exchange", "crypto"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.9, lastSeen: new Date() },
  { handle: "brian_armstrong", title: "Brian Armstrong", kind: "TWITTER", smart: 0.90, influence: 0.90, early: 0.65, authority: 0.88, followers: 1500000, following: 156, categories: ["FOUNDER"], tags: ["coinbase", "crypto"], source: "PLAYWRIGHT_PARSER", verified: true, confidence: 0.9, lastSeen: new Date() },
];

accounts.forEach(acc => {
  db.connections_unified_accounts.updateOne(
    { handle: acc.handle },
    { $set: { ...acc, updatedAt: new Date() }, $setOnInsert: { createdAt: new Date() } },
    { upsert: true }
  );
});

print("✅ Seeded " + accounts.length + " unified accounts");
'

echo "[4/6] Seeding taxonomy memberships..."
mongosh $MONGO_DB --quiet --eval '
const memberships = [
  // SMART group
  { accountId: "vitalikbuterin", group: "SMART", weight: 0.98, reasons: ["smart_score >= 0.6"] },
  { accountId: "a16z", group: "SMART", weight: 0.92, reasons: ["smart_score >= 0.6"] },
  { accountId: "paradigm", group: "SMART", weight: 0.91, reasons: ["smart_score >= 0.6"] },
  { accountId: "brian_armstrong", group: "SMART", weight: 0.90, reasons: ["smart_score >= 0.6"] },
  { accountId: "cz_binance", group: "SMART", weight: 0.88, reasons: ["smart_score >= 0.6"] },
  { accountId: "cobie", group: "SMART", weight: 0.88, reasons: ["smart_score >= 0.6"] },
  { accountId: "raoulpal", group: "SMART", weight: 0.86, reasons: ["smart_score >= 0.6"] },
  { accountId: "lookonchain", group: "SMART", weight: 0.85, reasons: ["smart_score >= 0.6"] },
  { accountId: "hsaka", group: "SMART", weight: 0.82, reasons: ["smart_score >= 0.6"] },
  { accountId: "pentoshi", group: "SMART", weight: 0.79, reasons: ["smart_score >= 0.6"] },
  // INFLUENCE group
  { accountId: "vitalikbuterin", group: "INFLUENCE", weight: 0.99, reasons: ["influence_score >= 0.6"] },
  { accountId: "cz_binance", group: "INFLUENCE", weight: 0.98, reasons: ["influence_score >= 0.6"] },
  { accountId: "a16z", group: "INFLUENCE", weight: 0.95, reasons: ["influence_score >= 0.6"] },
  { accountId: "paradigm", group: "INFLUENCE", weight: 0.92, reasons: ["influence_score >= 0.6"] },
  { accountId: "brian_armstrong", group: "INFLUENCE", weight: 0.90, reasons: ["influence_score >= 0.6"] },
  { accountId: "cobie", group: "INFLUENCE", weight: 0.88, reasons: ["influence_score >= 0.6"] },
  { accountId: "raoulpal", group: "INFLUENCE", weight: 0.85, reasons: ["influence_score >= 0.6"] },
  { accountId: "lookonchain", group: "INFLUENCE", weight: 0.78, reasons: ["influence_score >= 0.6"] },
  { accountId: "hsaka", group: "INFLUENCE", weight: 0.75, reasons: ["influence_score >= 0.6"] },
  { accountId: "pentoshi", group: "INFLUENCE", weight: 0.72, reasons: ["influence_score >= 0.6"] },
  // VC group
  { accountId: "a16z", group: "VC", weight: 0.95, reasons: ["category = VC"] },
  { accountId: "paradigm", group: "VC", weight: 0.92, reasons: ["category = VC"] },
];

memberships.forEach(m => {
  db.connections_taxonomy_membership.updateOne(
    { accountId: m.accountId, group: m.group },
    { $set: { ...m, computedAt: new Date() } },
    { upsert: true }
  );
});

print("✅ Seeded " + memberships.length + " taxonomy memberships");
'

echo "[5/6] Seeding influencer clusters..."
mongosh $MONGO_DB --quiet --eval '
const clusters = [
  {
    clusterId: 0,
    name: "VC_ELITE",
    members: ["a16z", "paradigm", "sequoia", "cobie", "hsaka", "binancelabs", "vitalikbuterin", "brian_armstrong"],
    avgInfluence: 0.85,
    avgTrustScore: 0.88,
    tokenFocus: ["ETH", "SOL", "ONDO", "ARB"],
    createdAt: new Date()
  },
  {
    clusterId: 1,
    name: "ANALYST_HUB",
    members: ["raoulpal", "pentoshi", "lookonchain", "glassnode"],
    avgInfluence: 0.72,
    avgTrustScore: 0.78,
    tokenFocus: ["BTC", "ETH", "SOL"],
    createdAt: new Date()
  }
];

clusters.forEach(c => {
  db.influencer_clusters.updateOne(
    { clusterId: c.clusterId },
    { $set: c },
    { upsert: true }
  );
});

// Cluster momentum
const momentum = [
  { token: "ONDO", clusterId: 0, score: 4.15, classification: "PUMP_LIKE", timestamp: new Date() },
  { token: "ARB", clusterId: 0, score: 2.41, classification: "PUMP_LIKE", timestamp: new Date() },
  { token: "SOL", clusterId: 0, score: 1.85, classification: "MOMENTUM", timestamp: new Date() },
  { token: "BTC", clusterId: 1, score: 0.92, classification: "ATTENTION", timestamp: new Date() },
  { token: "ETH", clusterId: 0, score: 0.55, classification: "ATTENTION", timestamp: new Date() },
];

momentum.forEach(m => {
  db.cluster_token_momentum.updateOne(
    { token: m.token },
    { $set: m },
    { upsert: true }
  );
});

print("✅ Seeded clusters and momentum");
'

echo "[6/6] Creating indexes..."
mongosh $MONGO_DB --quiet --eval '
// connections_author_profiles indexes
try { db.connections_author_profiles.createIndex({ "scores.influence_score": -1 }); } catch(e) {}
try { db.connections_author_profiles.createIndex({ "scores.risk_level": 1 }); } catch(e) {}
try { db.connections_author_profiles.createIndex({ author_id: 1 }, { unique: true }); } catch(e) {}

// connections_unified_accounts indexes
try { db.connections_unified_accounts.createIndex({ handle: 1 }, { unique: true, sparse: true }); } catch(e) {}
try { db.connections_unified_accounts.createIndex({ influence: -1 }); } catch(e) {}
try { db.connections_unified_accounts.createIndex({ smart: -1 }); } catch(e) {}
try { db.connections_unified_accounts.createIndex({ source: 1 }); } catch(e) {}

// taxonomy indexes
try { db.connections_taxonomy_membership.createIndex({ accountId: 1, group: 1 }); } catch(e) {}
try { db.connections_taxonomy_membership.createIndex({ group: 1, weight: -1 }); } catch(e) {}

print("✅ Indexes created/verified");
'

echo ""
echo "=============================================="
echo "SEED COMPLETE - Summary:"
echo "=============================================="
mongosh $MONGO_DB --quiet --eval '
print("connections_author_profiles: " + db.connections_author_profiles.countDocuments());
print("connections_unified_accounts: " + db.connections_unified_accounts.countDocuments());
print("connections_taxonomy_membership: " + db.connections_taxonomy_membership.countDocuments());
print("influencer_clusters: " + db.influencer_clusters.countDocuments());
print("twitter_egress_slots: " + db.twitter_egress_slots.countDocuments());
'
echo "=============================================="
