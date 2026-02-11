# FOMO - Connections Module PRD

## Версия: 1.1.0
## Дата: 2026-02-12

---

## Статус развертывания: ✅ ГОТОВО (ожидание куки)

### Работающие сервисы:
| Сервис | Порт | Статус |
|--------|------|--------|
| Frontend (React) | 3000 | ✅ RUNNING |
| Python Proxy | 8001 | ✅ RUNNING |
| Node.js Backend | 8003 | ✅ RUNNING |
| MongoDB | 27017 | ✅ RUNNING |
| Twitter Parser V2 | 5001 | ⏳ Требует запуска |

### Работающие API:
- ✅ `/api/health` - Health check
- ✅ `/api/connections/stats` - Connections статистика
- ✅ `/api/v4/twitter/accounts` - Twitter accounts (пусто - нужны куки)
- ✅ `/api/admin/twitter-egress/slots` - Parser slots

---

## Что нужно для работы парсера

### ⚠️ КРИТИЧНО: Загрузка Twitter Cookies

Парсер не будет работать без авторизованных cookies Twitter!

**Способы загрузки:**

1. **Chrome Extension** (`/frontend/public/fomo_extension_v1.3.0/`)
   - Установить расширение
   - Авторизоваться в Twitter
   - Export cookies через расширение

2. **API Upload**
   ```bash
   POST /api/v4/twitter/sessions
   {
     "label": "Account Name",
     "cookies": [
       {"name": "auth_token", "value": "xxx", "domain": ".twitter.com"},
       {"name": "ct0", "value": "xxx", "domain": ".twitter.com"}
     ]
   }
   ```

### Необходимые cookies:
| Cookie | Описание |
|--------|----------|
| auth_token | Основной токен авторизации |
| ct0 | CSRF токен |
| guest_id | Guest ID |
| twid | Twitter User ID |

---

## Архитектура модулей

### Connections Module
```
modules/connections/
├── adapters/           # Port implementations
├── api/                # REST API routes
├── config/             # Configuration
├── core/               # Business logic
│   ├── alerts/         # Alert system
│   ├── pilot/          # Pilot features
│   └── scoring/        # Influence scoring
├── db/                 # Database utilities
├── jobs/               # Background jobs
├── ml/                 # ML scoring (v1)
├── ml2/                # ML scoring (v2)
├── notifications/      # Telegram notifications
├── ports/              # External interfaces
└── index.ts            # Entry point
```

### Twitter Module
```
modules/twitter/
├── accounts/           # Account management
├── sessions/           # Session management
├── slots/              # Egress slots
├── parser/             # Parser integration
└── twitter.module.ts   # Module registration
```

---

## Implemented Features

### ✅ Phase 1 - Core
- [x] Connections module с plug-in архитектурой
- [x] Twitter user/session management
- [x] Egress slots для парсинга
- [x] Telegram notifications
- [x] Admin control plane

### ✅ Phase 2 - Analytics
- [x] Follow Graph v2
- [x] Cluster detection
- [x] Bot farm detection
- [x] Audience quality scoring
- [x] Authority scoring

### ✅ Phase 3 - ML
- [x] ML v1 scoring
- [x] ML v2 with shadow mode
- [x] Impact tracking
- [x] Feedback loop

### ⏳ Pending (требуют куки)
- [ ] Real-time Twitter parsing
- [ ] Live influence updates
- [ ] Active monitoring

---

## Следующие шаги

1. **Загрузить Twitter cookies** через расширение или API
2. **Запустить Twitter Parser V2** на порту 5001
3. **Настроить Telegram бота** для уведомлений
4. **Добавить influencer targets** для парсинга

---

## Environment Variables

### Backend (.env)
```
MONGO_URL=mongodb://localhost:27017
MONGODB_URI=mongodb://localhost:27017/connections_db
DB_NAME=connections_db
TELEGRAM_BOT_TOKEN=xxx
COOKIE_ENC_KEY=xxx (openssl rand -hex 32)
PARSER_URL=http://localhost:5001
```

### Frontend (.env)
```
REACT_APP_BACKEND_URL=https://your-domain.com
```

---

## Документация

- `/app/README.md` - Полная документация
- `/app/memory/PRD.md` - Этот файл
- `/app/backend/src/modules/connections/MODULE_BOUNDARY.md` - Boundary audit

---

Last Updated: 2026-02-12
