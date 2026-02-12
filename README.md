# FOMO - Connections Module + Twitter Parser

## Обзор

Платформа для анализа Twitter-аккаунтов и выявления:
- Bot farms (фермы ботов)
- Fake followers (фейковые подписчики)
- Influencer clusters (кластеры инфлюенсеров)
- Coordinated manipulation (координированные манипуляции)

## Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (React)                         │
│                      Port 3000                              │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│               Python FastAPI Proxy                          │
│                      Port 8001                              │
│    (Автоматически запускает Node.js backend)               │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│              Node.js Fastify Backend                        │
│                      Port 8003                              │
│                                                             │
│  Модули:                                                    │
│  ├── Connections (анализ аккаунтов)                        │
│  ├── Twitter User (сессии, аккаунты)                       │
│  ├── Twitter Parser Admin (слоты парсинга)                 │
│  ├── Truth Graph (причинно-следственные связи)             │
│  └── IPS (Informed Action Probability)                      │
└─────────────────────────────────────────────────────────────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
┌─────────────────────┐    ┌─────────────────────┐
│  Twitter Parser V2  │    │      MongoDB        │
│     Port 5001       │    │    Port 27017       │
│  (Playwright +      │    │                     │
│   Cookie Sessions)  │    │  DB: connections_db │
└─────────────────────┘    └─────────────────────┘
```

## Требования

- Node.js >= 20.0.0
- Python >= 3.11
- MongoDB >= 6.0
- Chromium (для Playwright)

## Установка

### 1. Клонирование репозитория

```bash
git clone https://github.com/svetlanaslinko057/margeeee1.git
cd margeeee1
```

### 2. Установка зависимостей

```bash
# Backend (Node.js)
cd backend && yarn install

# Frontend
cd ../frontend && yarn install

# Twitter Parser
cd ../twitter-parser-v2 && yarn install

# Python dependencies
pip install httpx websockets python-dotenv

# Playwright browsers
cd ../twitter-parser-v2 && npx playwright install chromium
```

### 3. Настройка окружения

**Backend** (`/app/backend/.env`):
```env
MONGO_URL=mongodb://localhost:27017
MONGODB_URI=mongodb://localhost:27017/connections_db
DB_NAME=connections_db
NODE_ENV=development
PORT=8001
CORS_ORIGINS=*
LOG_LEVEL=info
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
PUBLIC_BASE_URL=https://your-domain.com
WS_ENABLED=true
COOKIE_ENC_KEY=<generate: openssl rand -hex 32>
WEBHOOK_API_KEY=<generate: openssl rand -hex 32>
PARSER_URL=http://localhost:5001
```

**Frontend** (`/app/frontend/.env`):
```env
REACT_APP_BACKEND_URL=https://your-domain.com
WDS_SOCKET_PORT=443
```

**Twitter Parser** (`/app/twitter-parser-v2/.env`):
```env
PORT=5001
MONGO_URL=mongodb://localhost:27017/connections_db
HEADLESS=true
```

### 4. Инициализация базы данных

```bash
# Запуск MongoDB
mongod --bind_ip_all &

# Создание слотов
mongosh connections_db --eval '
db.twitter_egress_slots.insertOne({
  label: "Parser Slot",
  type: "LOCAL_PARSER",
  enabled: true,
  localParser: { url: "http://localhost:5001" },
  health: { status: "HEALTHY" },
  limits: { requestsPerHour: 100 }
});

db.proxy_slots.insertOne({
  name: "direct-slot",
  host: "DIRECT",
  port: 0,
  status: "ACTIVE",
  enabled: true,
  type: "DIRECT"
});
'
```

## Запуск

### Supervisor (рекомендуется)

```bash
sudo supervisorctl restart backend frontend
sudo supervisorctl status
```

### Вручную

```bash
# Backend (Python proxy + Node.js)
cd /app/backend
uvicorn server:app --host 0.0.0.0 --port 8001 --reload

# Frontend
cd /app/frontend
yarn start

# Twitter Parser (опционально, для парсинга)
cd /app/twitter-parser-v2
npx tsx src/server.ts
```

## API Endpoints

### Health Check
```bash
curl http://localhost:8001/api/health
# {"ok":true,"service":"fomo-backend","mode":"minimal"}
```

### Connections Module
```bash
# Статистика
curl http://localhost:8001/api/connections/stats

# Unified accounts
curl http://localhost:8001/api/connections/unified/accounts
```

### Twitter Module
```bash
# Accounts (требуются куки!)
curl http://localhost:8001/api/v4/twitter/accounts

# Egress Slots
curl http://localhost:8001/api/admin/twitter-egress/slots

# Sessions
curl http://localhost:8001/api/v4/twitter/sessions
```

## Быстрый старт

### После клонирования - запустить один раз:

```bash
# 1. Установка зависимостей
cd /app/backend && yarn install
cd /app/frontend && yarn install
cd /app/twitter-parser-v2 && yarn install

# 2. Инициализация базы данных с seed данными
chmod +x /app/scripts/seed_all.sh
/app/scripts/seed_all.sh

# 3. Перезапуск сервисов
sudo supervisorctl restart backend frontend
```

### Или полный startup:

```bash
chmod +x /app/scripts/startup.sh
/app/scripts/startup.sh
sudo supervisorctl restart backend frontend
```

---

## Seed Data

Проект включает seed данные с реальными Twitter аккаунтами для демонстрации:

### Автоматическая инициализация
```bash
# Запустить startup script
/app/scripts/startup.sh
```

### Включённые аккаунты (10 профилей)

| Handle | Category | Influence | Followers |
|--------|----------|-----------|-----------|
| @vitalikbuterin | FOUNDER | 990 | 5.2M |
| @cz_binance | FOUNDER | 980 | 8.9M |
| @a16z | VC | 950 | 1.2M |
| @paradigm | VC | 920 | 450K |
| @brian_armstrong | FOUNDER | 900 | 1.5M |
| @cobie | KOL | 880 | 890K |
| @raoulpal | KOL | 850 | 1.1M |
| @lookonchain | ANALYST | 780 | 780K |
| @hsaka | KOL | 750 | 220K |
| @pentoshi | KOL | 720 | 680K |

### MongoDB коллекции с данными

| Collection | Records | Description |
|------------|---------|-------------|
| connections_author_profiles | 10 | Main profiles for Connections page |
| connections_unified_accounts | 18 | Unified accounts for Unified page |
| connections_taxonomy_membership | 70 | Taxonomy labels |
| twitter_accounts | 23 | Twitter accounts data |
| influencer_clusters | 2 | Cluster data |

---

## Загрузка Twitter Cookies

### ⚠️ ВАЖНО: Без куки парсер не работает!

Для работы Twitter парсера необходимо загрузить cookies авторизованного Twitter аккаунта.

### Способ 1: Chrome Extension

1. Установите расширение из `/frontend/public/fomo_extension_v1.3.0/`
2. Авторизуйтесь в Twitter
3. Нажмите кнопку "Export Cookies" в расширении
4. Загрузите JSON через API

### Способ 2: Через API

```bash
# Формат cookies
curl -X POST http://localhost:8001/api/v4/twitter/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Main Account",
    "cookies": [
      {"name": "auth_token", "value": "xxx", "domain": ".twitter.com"},
      {"name": "ct0", "value": "xxx", "domain": ".twitter.com"}
    ]
  }'
```

### Необходимые cookies

| Cookie | Описание |
|--------|----------|
| auth_token | Токен авторизации |
| ct0 | CSRF токен |
| guest_id | Guest ID |
| twid | Twitter User ID |

## Структура проекта

```
/app
├── backend/
│   ├── src/
│   │   ├── modules/
│   │   │   ├── connections/     # 🔷 Connections Module
│   │   │   ├── twitter/         # Twitter integration
│   │   │   ├── twitter-user/    # Session management
│   │   │   └── twitter-admin/   # Admin control plane
│   │   ├── core/
│   │   │   ├── notifications/   # Telegram notifications
│   │   │   └── admin/           # Admin auth
│   │   └── db/                  # Database connections
│   ├── server.py               # Python proxy
│   └── package.json
│
├── frontend/
│   ├── src/
│   │   ├── pages/              # Page components
│   │   ├── components/         # UI components
│   │   └── api/                # API client
│   └── public/
│       └── fomo_extension_v1.3.0/  # Chrome extension
│
├── twitter-parser-v2/
│   ├── src/
│   │   ├── browser/            # Playwright browser manager
│   │   ├── queue/              # Task queue
│   │   └── server.ts           # Express server
│   └── extension/              # Extension source
│
└── scripts/
    └── startup.sh              # DB initialization
```

## Модули Connections

| Модуль | Описание |
|--------|----------|
| Unified Accounts | Управление Twitter аккаунтами |
| Follow Graph | Граф подписок |
| Clusters | Кластеризация инфлюенсеров |
| Bot Farms | Детекция ферм ботов |
| Audience Quality | Качество аудитории |
| Reality Gate | Валидация on-chain |
| Influence Adjustment | Коррекция influence score |

## Telegram Bot

Бот для уведомлений о:
- Статусе сессий (🟢 OK, 🟠 Stale, 🔴 Invalid)
- Завершении/отмене парсинга
- Сигналах Connections

### Команды

```
/start - Регистрация
/status - Статус подключения
/alerts - Настройки уведомлений
/connections on|off - Alerts Connections
/twitter on|off - Alerts Twitter
/disconnect - Отключение
```

## Troubleshooting

### Node.js backend не запускается

```bash
# Проверьте логи
tail -f /var/log/supervisor/backend-node.err.log

# Перезапустите
sudo supervisorctl restart backend
```

### Parser Slot ERROR

```bash
# Проверьте что parser запущен
curl http://localhost:5001/health

# Запустите parser
cd /app/twitter-parser-v2 && npx tsx src/server.ts
```

### MongoDB connection error

```bash
# Проверьте MongoDB
mongosh --eval "db.runCommand('ping')"

# Перезапустите
sudo supervisorctl restart mongodb
```

## Лицензия

Private / Internal Use Only

---

**Версия**: 1.0.0  
**Дата обновления**: 2026-02-12
