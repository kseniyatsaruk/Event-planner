# Event Planner — local event planning app

This file is the guide for Claude Code (and any developer) working in this repository. The project is fully local: no cloud database or paid APIs, it runs on a developer machine with two commands.

## What this project is

A web app for planning a single event (wedding, birthday, corporate party, etc.) by one organizer. The organizer registers, creates an event, and then works with it through a sidebar with sections:

1. **Overview** — name, date, venue (address + point on a map), description.
2. **Checklist** — preparation tasks (category, due date, status, linked vendor).
3. **Vendors** — contacts, service category, price, negotiation status.
4. **Guests** — guest list, contacts, RSVP status, notes (dietary restrictions, etc.). Guest statuses are set manually by the organizer only — there is no public RSVP page for guests.
5. **Seating** — a visual floor plan: tables can be dragged around the canvas, guests can be dragged onto a table (drag-and-drop).

One user = one account, sees only their own events. There is no multi-user collaboration on a single event (can be added later).

The UI supports two languages, English and Russian, switchable at runtime (see "Internationalization (i18n)" below). User-entered content (event names, guest names, checklist text, notes, etc.) is never auto-translated — only the interface chrome is localized.

## Stack

**Frontend:** React (Vite), Material UI (MUI v6), react-router-dom, dnd-kit (seating), react-leaflet + Leaflet (map, OpenStreetMap tiles — no API keys), axios, react-i18next (UI localization, EN/RU).

**Backend:** Go, `chi` router, SQLite (`modernc.org/sqlite` — pure Go, no cgo, so the build stays simple on any machine), `golang-jwt/jwt` for tokens, `golang.org/x/crypto/bcrypt` for passwords, `golang-migrate` (or plain SQL files applied on startup) for migrations.

**No Docker.** Backend and frontend run directly (`go run`, `npm run dev`). The database is a file at `backend/data/eventplanner.db`, created automatically on first run.

## Repository structure

```
event-planner/
├── CLAUDE.md
├── backend/
│   ├── go.mod
│   ├── cmd/
│   │   └── server/
│   │       └── main.go            # entry point, config loading, router startup
│   ├── internal/
│   │   ├── config/                # env vars (PORT, JWT_SECRET, DB_PATH)
│   │   ├── db/                    # open sqlite, run migrations
│   │   ├── models/                # User, Event, ChecklistItem, Vendor, Guest, Table structs
│   │   ├── auth/                  # password hashing, JWT issue/validate, middleware
│   │   └── handlers/              # one HTTP handler file per entity
│   ├── migrations/                # applied in filename order on startup, embedded via embed.go
│   │   ├── 0001_init.sql
│   │   ├── 0002_add_seat_number.sql
│   │   └── 0003_unique_guest_seat.sql
│   └── data/                      # sqlite file (gitignored)
├── frontend/
    ├── package.json
    ├── vite.config.js             # proxy /api -> http://localhost:8080
    ├── index.html
    └── src/
        ├── main.jsx
        ├── App.jsx                 # routes + ThemeProvider + i18n provider
        ├── theme.js                 # MUI theme
        ├── i18n/
        │   ├── index.js             # i18next init, language detection/persistence
        │   └── locales/
        │       ├── en.json
        │       └── ru.json
        ├── api/                     # client.js (axios instance) + one file per resource
        ├── context/
        │   └── AuthContext.jsx      # token in localStorage, current user
        ├── components/
        │   ├── layout/
        │   │   ├── AppShell.jsx     # top bar (incl. language switcher) + Outlet
        │   │   ├── EventSidebar.jsx # items: Overview/Checklist/Vendors/Guests/Seating
        │   │   └── ProtectedRoute.jsx
        │   ├── map/
        │   │   └── LocationPicker.jsx  # react-leaflet, click on map -> lat/lng + optional reverse geocode
        │   └── seating/
        │       ├── SeatingCanvas.jsx   # dnd-kit context, canvas
        │       ├── TableShape.jsx      # draggable table
        │       └── UnassignedGuestsPanel.jsx
        └── pages/
            ├── LoginPage.jsx
            ├── RegisterPage.jsx
            ├── EventsListPage.jsx      # list of events + create new
            └── event/
                ├── EventOverviewPage.jsx
                ├── ChecklistPage.jsx
                ├── VendorsPage.jsx
                ├── GuestsPage.jsx
                └── SeatingPage.jsx
└── mobile/                         # Flutter app, Android + iOS targets
    ├── pubspec.yaml
    ├── l10n.yaml                   # arb-dir/output config for flutter gen-l10n
    └── lib/
        ├── main.dart                # MaterialApp, routes, MultiProvider wiring
        ├── api/
        │   ├── api_client.dart      # Dio instance; base URL + auth header resolved per-request from SettingsStore/AuthStore
        │   ├── api_error.dart
        │   ├── auth_api.dart
        │   ├── events_api.dart
        │   ├── checklist_api.dart
        │   ├── vendors_api.dart
        │   ├── guests_api.dart
        │   ├── tables_api.dart
        │   └── geocoding_api.dart   # Nominatim reverse geocoding, separate Dio instance (own base URL)
        ├── models/                  # Event, Guest, Vendor, ChecklistItem, TableModel, UserInfo, AuthResult
        ├── state/
        │   ├── auth_store.dart      # ChangeNotifier; JWT persisted via flutter_secure_storage
        │   └── settings_store.dart  # ChangeNotifier; server base URL + language persisted via shared_preferences
        ├── screens/
        │   ├── splash_screen.dart
        │   ├── login_screen.dart
        │   ├── register_screen.dart
        │   ├── settings_screen.dart      # server address entry + "test connection"
        │   ├── events_list_screen.dart
        │   └── event/
        │       ├── event_shell_screen.dart  # bottom nav across the 5 sections, mirrors EventSidebar
        │       ├── event_overview_tab.dart
        │       ├── checklist_tab.dart
        │       ├── vendors_tab.dart
        │       ├── guests_tab.dart
        │       └── seating_tab.dart
        ├── widgets/
        │   ├── language_switcher.dart
        │   └── location_picker_map.dart  # flutter_map + latlong2, tap-to-pick, parity with web LocationPicker
        └── l10n/
            ├── app_en.arb / app_ru.arb    # source strings (flat, not namespaced)
            ├── format_date.dart
            └── generated/                 # flutter gen-l10n output, gitignored
```

## Data model (SQLite)

```sql
users (
  id INTEGER PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

events (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  name TEXT NOT NULL,
  event_date DATETIME,
  description TEXT,
  location_address TEXT,
  location_lat REAL,
  location_lng REAL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

vendors (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT,               -- catering, venue, decor, music, photo/video, transport, other
  contact_name TEXT,
  phone TEXT,
  email TEXT,
  price REAL,
  status TEXT NOT NULL DEFAULT 'contacted',  -- contacted | negotiating | confirmed | paid | cancelled
  notes TEXT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

tables (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  label TEXT NOT NULL,          -- "Table 1"
  capacity INTEGER NOT NULL DEFAULT 8,
  shape TEXT NOT NULL DEFAULT 'round',  -- round | rectangle
  pos_x REAL NOT NULL DEFAULT 0,
  pos_y REAL NOT NULL DEFAULT 0,
  rotation REAL NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

checklist_items (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,              -- e.g. "Venue", "Catering", "Decor", "Music", "Photo/Video"
  due_date DATETIME,
  status TEXT NOT NULL DEFAULT 'todo',   -- todo | in_progress | done
  vendor_id INTEGER REFERENCES vendors(id) ON DELETE SET NULL,
  sort_order INTEGER DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)

guests (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  rsvp_status TEXT NOT NULL DEFAULT 'pending',  -- pending | invited | confirmed | declined
  plus_one INTEGER NOT NULL DEFAULT 0,          -- boolean 0/1
  notes TEXT,                                    -- dietary restrictions, wishes, etc.
  table_id INTEGER REFERENCES tables(id) ON DELETE SET NULL,
  seat_number INTEGER,                           -- seat within table_id; only meaningful together
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
)
```

Tables must be created in this order in the migration (`users` → `events` → `vendors` → `tables` → `checklist_items` → `guests`) so foreign keys reference tables that already exist. Every table except `users` is always filtered by `event_id`, and `events` itself is filtered by `user_id` from the JWT. No handler should ever return data belonging to another user's event.

`seat_number` was added in a later migration, along with a partial unique index on `guests(table_id, seat_number)` (only enforced when both are non-null) so two guests can never be assigned the same seat at the same table. The two columns are always written together through the guest-table endpoint below — a guest is never given a `seat_number` without a `table_id`.

Status/category values (`todo`, `in_progress`, `contacted`, `pending`, etc.) are stored in English regardless of UI language — they are enum-like identifiers, not display text. The frontend maps each value to a localized label through i18n (see below); no casing translation is needed since the API already returns camelCase field names (see Conventions).

## API

Prefix `/api`. Everything except `/api/health`, `/api/auth/register`, and `/api/auth/login` requires an `Authorization: Bearer <token>` header.

```
GET    /api/health                -> { status, db }   # no auth; used by the mobile app's "test connection" check

POST   /api/auth/register        { email, password, name }
POST   /api/auth/login           { email, password } -> { token }
GET    /api/auth/me

GET    /api/events
POST   /api/events
GET    /api/events/{eventId}
PUT    /api/events/{eventId}
DELETE /api/events/{eventId}

GET    /api/events/{eventId}/checklist
POST   /api/events/{eventId}/checklist
PUT    /api/events/{eventId}/checklist/{itemId}
DELETE /api/events/{eventId}/checklist/{itemId}

GET    /api/events/{eventId}/vendors
POST   /api/events/{eventId}/vendors
PUT    /api/events/{eventId}/vendors/{vendorId}
DELETE /api/events/{eventId}/vendors/{vendorId}

GET    /api/events/{eventId}/guests
POST   /api/events/{eventId}/guests
PUT    /api/events/{eventId}/guests/{guestId}
DELETE /api/events/{eventId}/guests/{guestId}
PATCH  /api/events/{eventId}/guests/{guestId}/table   { tableId, seatNumber } | { tableId: null }   # assign/unassign a table + seat

GET    /api/events/{eventId}/tables
POST   /api/events/{eventId}/tables
PUT    /api/events/{eventId}/tables/{tableId}    # includes pos_x/pos_y/rotation updates while dragging
DELETE /api/events/{eventId}/tables/{tableId}
```

When a table is deleted, guests assigned to it are not deleted — their `table_id` is reset to `NULL` (see `ON DELETE SET NULL` above).

Error responses are language-agnostic: the backend returns a machine-readable error code (e.g. `{"error": "invalid_credentials"}`), never a human-readable sentence. The frontend maps error codes to localized messages via i18n. This keeps the backend free of any localization concerns.

## Frontend routes

```
/login
/register
/events                              — list of events + "Create" button
/events/:eventId                     — redirects to /overview
/events/:eventId/overview            — name, date, LocationPicker (map)
/events/:eventId/checklist
/events/:eventId/vendors
/events/:eventId/guests
/events/:eventId/seating             — SeatingCanvas (dnd-kit)
```

`EventSidebar` is only rendered inside `/events/:eventId/*` and contains the 5 items from the "What this project is" section. Everything under `/events/*` is wrapped in `ProtectedRoute`, which checks for a token in `AuthContext` and otherwise redirects to `/login`.

## Mobile app

`mobile/` is a Flutter client covering the same feature set as the web app (`EventShellScreen` hosts the 5 sections behind a bottom nav bar, mirroring `EventSidebar`). It is a thin client against the same `/api` backend — there are no mobile-specific endpoints, and no server-side code lives under `mobile/`.

Because there's no hosting for this project, the phone/emulator and the backend are two separate machines on the same local network rather than `localhost` and a port on one machine. The backend's address is therefore never hardcoded: it's entered once in the app's Settings screen (`SettingsScreen` / `SettingsStore`), persisted locally, and sent as `Authorization`-bearing requests through `ApiClient`, which resolves the base URL and JWT fresh on every call. The JWT itself is kept in `flutter_secure_storage`, not `shared_preferences`, so it survives restarts without sitting in plaintext.

## Internationalization (i18n)

The UI ships in English and Russian, switchable at runtime, with English as the default/fallback.

**Library:** `react-i18next` + `i18next`, initialized in `src/i18n/index.js`.

**Locale files:** `src/i18n/locales/en.json` and `src/i18n/locales/ru.json`, namespaced by feature (`common`, `auth`, `events`, `checklist`, `vendors`, `guests`, `seating`) — one flat JSON per language, not per-component files.

**Language detection & persistence:** on first load, detect from `navigator.language`; after that, the user's explicit choice is stored in `localStorage` (`eventplanner_lang`) and takes priority. A language switcher (EN/RU) lives in `AppShell`'s top bar, visible on every page.

**What gets translated and what doesn't:**
- Translated: all UI chrome — labels, buttons, menu items, form field labels, validation messages, status/category display labels (mapped from the English enum values stored in the DB, e.g. `status: "todo"` → "To do" / "Сделать"), date/number formatting.
- Never translated: user-entered content — event names, guest names, checklist item titles/descriptions, vendor notes, addresses, etc. There is no machine-translation call anywhere in the app (that would break the "fully local, no external services" requirement), so this content simply displays as typed regardless of the selected UI language.

**MUI locale:** wrap the theme with MUI's built-in locale objects (`enUS` / `ruRU` from `@mui/material/locale`) via `createTheme(theme, i18n.language === 'ru' ? ruRU : enUS)`, so built-in component strings (pagination, date pickers, etc.) follow the selected language too. If `@mui/x-date-pickers` is used anywhere, apply its matching locale text as well.

**Dates:** format with `Intl.DateTimeFormat` (or `date-fns` with the `enUS`/`ru` locale) using the current i18n language, so the same stored `event_date` renders as e.g. "August 20, 2026" or "20 августа 2026" depending on the UI language.

**Map:** Nominatim (OpenStreetMap's geocoding service, used for optional reverse geocoding in `LocationPicker`) accepts an `accept-language` query parameter — pass the current UI language so returned address text matches it. This is a nice-to-have, not required for the map picker itself to work.

**Mobile:** the Flutter app ships the same two languages (EN/RU) via `flutter_localizations` + generated ARB-based localizations (`lib/l10n/app_en.arb`, `app_ru.arb`), following the same rule as the web app — UI chrome is translated, user-entered content never is. Language choice is persisted through `SettingsStore` (`shared_preferences`, same `eventplanner_lang` key as the web app's `localStorage`), and while unset falls back to the device locale rather than an explicit detection step, matching the web app's "detect from `navigator.language` on first load" behavior.

## Running locally

Backend (from `backend/`):
```
go mod tidy
go run ./cmd/server
```
Listens on `:8080` by default (`PORT` env var). On startup it applies migrations to `data/eventplanner.db`, creating the file and folder if they don't exist. `JWT_SECRET` is read from the environment; if unset, a development default is used (see `internal/config`).

Optional hot reload: `go install github.com/air-verse/air@latest`, then run `air` instead of `go run`.

Frontend (from `frontend/`):
```
npm install
npm run dev
```
Vite runs on `:5173` and proxies all `/api/*` requests to `http://localhost:8080` (configured in `vite.config.js`) — thanks to this, no CORS setup is needed on the Go side; the frontend always calls the relative `/api`.

Mobile (from `mobile/`):
```
flutter pub get
flutter run                 # pick a connected device/emulator, or pass -d <id>
```
Unlike the web dev server, the app has no proxy to fall back on: run the backend with `PORT` bound as usual, find the backend machine's LAN IP (e.g. `ipconfig` on Windows), and enter `http://<that-ip>:8080` in the app's Settings screen on first launch (an Android emulator reaching a backend on the same physical machine can instead use the emulator's host alias, `10.0.2.2`). "Test connection" on that screen hits `/api/health` to confirm the address is reachable before saving it.

## Conventions

- Go: standard `gofmt`, wrap errors with `fmt.Errorf("...: %w", err)`, keep handlers thin — all data-access logic lives in `internal/db`/entity repositories.
- React: functional components and hooks, no class components. API calls go through the thin layer in `src/api/*`; components don't fetch directly.
- MUI: theme and palette are defined once in `src/theme.js`; components use `sx`/theme tokens, not inline colors.
- All user-facing strings in components go through `useTranslation()` / `t(...)` — no hardcoded English (or Russian) strings in JSX.
- SQLite columns are snake_case, but every Go model struct tags its JSON fields camelCase (e.g. `guests.table_id` serializes as `"tableId"`), so the API itself speaks camelCase end-to-end — `src/api/*` and the Flutter `api/*_api.dart` files pass request/response bodies straight through with no casing translation. Enum-like values (`status`, `category`, `shape`) stay in English at the data layer; only their displayed labels are localized.
- Each entity (checklist item, vendor, guest, table) gets its own CRUD — handlers are not shared between entities.

## Not in the first version (can be discussed later)

- Multi-user collaboration on a single event.
- A public RSVP page for guests via a link.
- Export (PDF/Excel) of the guest list or checklist.
- Notifications/reminders for checklist due dates.
- Automatic translation of user-entered content.
