# FOMO - Connections Module PRD

## Версия: 1.2.0
## Дата: 2026-02-12

---

## Статус: ✅ ГОТОВО С SEED DATA

### Работающие сервисы:
| Сервис | Порт | Статус |
|--------|------|--------|
| Frontend (React) | 3000 | ✅ RUNNING |
| Python Proxy | 8001 | ✅ RUNNING |
| Node.js Backend | 8003 | ✅ RUNNING |
| MongoDB | 27017 | ✅ RUNNING |
| Twitter Parser V2 | 5001 | ⏳ Требует cookies |

### Seed данные загружены:
- ✅ 10 профилей в `connections_author_profiles`
- ✅ 18 unified accounts в `connections_unified_accounts`
- ✅ 70 taxonomy memberships
- ✅ 23 twitter accounts
- ✅ 2 influencer clusters

### Работающие страницы с данными:
- ✅ `/connections` - 10 аккаунтов (Vitalik, CZ, a16z, paradigm...)
- ✅ `/connections?preset=SMART` - Unified page с taxonomy
- ✅ API `/api/connections/accounts` - полный список
- ✅ API `/api/connections/unified` - facet/preset query

---

## Что нужно для парсинга

### ⚠️ Twitter Cookies (для live данных)

Seed данные статичны. Для получения live данных из Twitter:

1. **Установить Chrome Extension** (`/frontend/public/fomo_extension_v1.3.0/`)
2. **Экспортировать cookies** авторизованного Twitter аккаунта
3. **Загрузить через API**:
   ```bash
   POST /api/v4/twitter/sessions
   { "label": "...", "cookies": [...] }
   ```

---

## Архитектура

```
Frontend (3000) → Python Proxy (8001) → Node.js Fastify (8003) → MongoDB
                                              ↓
                                     Twitter Parser V2 (5001)
```

## Seed аккаунты

| Handle | Category | Influence | Risk |
|--------|----------|-----------|------|
| vitalikbuterin | FOUNDER | 990 | Low |
| cz_binance | FOUNDER | 980 | Low |
| a16z | VC | 950 | Low |
| paradigm | VC | 920 | Low |
| brian_armstrong | FOUNDER | 900 | Low |
| cobie | KOL | 880 | Low |
| raoulpal | KOL | 850 | Low |
| lookonchain | ANALYST | 780 | Low |
| hsaka | KOL | 750 | Medium |
| pentoshi | KOL | 720 | Medium |

---

## Следующие шаги

1. **Загрузить Twitter cookies** для live парсинга
2. **Запустить Parser V2** на порту 5001
3. **Сохранить на GitHub**

---

Last Updated: 2026-02-12
