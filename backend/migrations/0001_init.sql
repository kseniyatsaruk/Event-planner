CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS events (
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
);

CREATE TABLE IF NOT EXISTS vendors (
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
);

CREATE TABLE IF NOT EXISTS tables (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  label TEXT NOT NULL,          -- "Table 1"
  capacity INTEGER NOT NULL DEFAULT 8,
  shape TEXT NOT NULL DEFAULT 'round',  -- round | rectangle
  pos_x REAL NOT NULL DEFAULT 0,
  pos_y REAL NOT NULL DEFAULT 0,
  rotation REAL NOT NULL DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS checklist_items (
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
);

CREATE TABLE IF NOT EXISTS guests (
  id INTEGER PRIMARY KEY,
  event_id INTEGER NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  rsvp_status TEXT NOT NULL DEFAULT 'pending',  -- pending | invited | confirmed | declined
  plus_one INTEGER NOT NULL DEFAULT 0,          -- boolean 0/1
  notes TEXT,                                    -- dietary restrictions, wishes, etc.
  table_id INTEGER REFERENCES tables(id) ON DELETE SET NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
