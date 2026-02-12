# FOMO Connections Module - PRD

## Версия: 1.3.0 (Seed Fixed)
## Дата: 2026-02-12

---

## ✅ ИСПРАВЛЕНО: Автоматический Seed

### Скрипты:

| Файл | Описание |
|------|----------|
| `/app/scripts/seed_all.sh` | Полный seed всех данных (10 профилей, taxonomy, clusters) |
| `/app/scripts/startup.sh` | Startup скрипт (вызывает seed_all.sh) |

### Запуск при развертывании:

```bash
# Обязательно после клонирования:
chmod +x /app/scripts/seed_all.sh /app/scripts/startup.sh
/app/scripts/seed_all.sh
sudo supervisorctl restart backend frontend
```

### Что seed создаёт:

| Collection | Records | Описание |
|------------|---------|----------|
| connections_author_profiles | 10 | Главная страница /connections |
| connections_unified_accounts | 10 | Unified page с facets |
| connections_taxonomy_membership | 22 | Taxonomy presets (SMART, INFLUENCE, VC) |
| influencer_clusters | 2 | Кластеры (VC_ELITE, ANALYST_HUB) |
| twitter_egress_slots | 1 | Parser Slot |
| proxy_slots | 1 | Direct slot |

---

## Архитектура

```
Frontend (3000) → Python Proxy (8001) → Node.js (8003) → MongoDB (27017)
                                              ↓
                                     Parser V2 (5001) [requires cookies]
```

---

## Seed Аккаунты

| Handle | Category | Influence | Risk |
|--------|----------|-----------|------|
| @vitalikbuterin | FOUNDER | 990 | Low |
| @cz_binance | FOUNDER | 980 | Low |
| @a16z | VC | 950 | Low |
| @paradigm | VC | 920 | Low |
| @brian_armstrong | FOUNDER | 900 | Low |
| @cobie | KOL | 880 | Low |
| @raoulpal | KOL | 850 | Low |
| @lookonchain | ANALYST | 780 | Low |
| @hsaka | KOL | 750 | Medium |
| @pentoshi | KOL | 720 | Medium |

---

## Важные коллекции MongoDB

### Для /connections page:
- `connections_author_profiles` - использует `listAuthorProfiles()`

### Для /connections?preset=X:
- `connections_unified_accounts` - использует `getUnifiedAccounts()`
- `connections_taxonomy_membership` - для presets (SMART, INFLUENCE, VC)

### Для парсинга:
- `twitter_egress_slots` - слоты для парсера
- `user_twitter_accounts` - Twitter сессии с cookies

---

## API Endpoints

```bash
# Main page
GET /api/connections/accounts

# Unified page
GET /api/connections/unified?preset=SMART
GET /api/connections/unified?facet=INFLUENCE

# Stats
GET /api/connections/unified/stats
```

---

## Следующие шаги

1. ✅ Seed данные зафиксированы в `/app/scripts/seed_all.sh`
2. Сохранить на GitHub
3. При следующем развертывании: просто запустить `seed_all.sh`

---

Last Updated: 2026-02-12
