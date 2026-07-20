# Technical Design Document
## Milk Daily Tracker

---

## 1. Architecture Overview

```
┌─────────────────────────────────────┐
│           UI Layer                  │
│   (Flutter Widgets & Screens)       │
├─────────────────────────────────────┤
│         State Management            │
│   (StatefulWidget + setState)       │
├─────────────────────────────────────┤
│        Database Layer               │
│   (sqflite + database_helper.dart)  │
├─────────────────────────────────────┤
│         SQLite Database             │
│   (Local on device storage)         │
└─────────────────────────────────────┘
```

### Why SQLite?
- **Free:** No subscription costs
- **Offline:** 100% works without internet
- **Reliable:** ACID-compliant, guarantees data consistency
- **Proven:** Used in millions of mobile apps
- **Simple:** Perfect for this scale (~3 customers, daily entries)

---

## 2. Tech Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter |
| Language | Dart |
| Database | SQLite (sqflite package) |
| State | StatefulWidget + setState |
| Navigation | Named routes |
| File System | path_provider |
| Backup | File-based (export/import SQLite DB) |

### Key Dependencies
```yaml
dependencies:
  sqflite: ^2.3.0          # SQLite plugin
  path: ^1.8.0              # Path manipulation
  path_provider: ^2.1.0     # App directories
  intl: ^0.18.0             # Date formatting
  share_plus: ^7.0.0        # Share backup files
```

---

## 3. Database Schema

### 3.1 Tables

```sql
-- Customers table
CREATE TABLE customers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Price history table
CREATE TABLE prices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    price_per_litre REAL NOT NULL,
    effective_from TEXT NOT NULL,
    effective_to TEXT  -- NULL means currently active
);

-- Milk entries table
CREATE TABLE milk_entries (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    date TEXT NOT NULL,  -- YYYY-MM-DD format
    quantity_litres REAL NOT NULL,
    price_per_litre REAL NOT NULL,  -- Snapshot at time of entry
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Indexes for performance
CREATE INDEX idx_entries_date ON milk_entries(date);
CREATE INDEX idx_entries_customer ON milk_entries(customer_id);
CREATE INDEX idx_prices_effective ON prices(effective_from, effective_to);
```

### 3.2 Relationships
```
customers (1) ──── (many) milk_entries
prices (1) ──── (many) milk_entries (via price snapshot)
```

---

## 4. Data Flow Diagrams

### 4.1 Add Milk Entry
```
User taps "Add Entry"
  → Customer list displayed
  → User selects customer
  → Enters quantity (litres)
  → App fetches current price from prices table
  → Inserts into milk_entries with:
    - customer_id
    - date (today)
    - quantity_litres
    - price_per_litre (snapshot)
  → Returns to home, entry appears
```

### 4.2 Change Price
```
User goes to Settings
  → Taps "Change Price"
  → Enters new price
  → App updates current price:
    - Sets effective_to on old price
    - Inserts new price with effective_from = today
  → Future entries use new price
  → Past entries retain old price (via snapshot)
```

### 4.3 Backup/Restore
```
Backup:
  → User taps "Backup"
  → App copies SQLite DB file
  → Saves to Downloads or shares via share_plus

Restore:
  → User selects backup file
  → App replaces current DB
  → App restarts with restored data
```

---

## 5. UI Screen Designs

### 5.1 Home Screen
```
┌─────────────────────────────────┐
│  🥛 Milk Daily Tracker          │
├─────────────────────────────────┤
│  Today: 15 July 2026            │
│  Price: ₹55/L                   │
├─────────────────────────────────┤
│  TODAY'S ENTRIES                │
│  ┌─────────────────────────┐    │
│  │ Ramesh    │ 1.0L │ ₹55  │    │
│  ├─────────────────────────┤    │
│  │ Suresh    │ 1.5L │ ₹82  │    │
│  ├─────────────────────────┤    │
│  │ Priya     │ 0.5L │ ₹27  │    │
│  └─────────────────────────┘    │
│                                 │
│  Total: 3.0L  │  Total: ₹165   │
├─────────────────────────────────┤
│                                 │
│     [ + ADD ENTRY ]             │
│                                 │
├─────────────────────────────────┤
│  🏠 Home │ 👥 Customers │      │
│  📋 History │ ⚙️ Settings      │
└─────────────────────────────────┘
```

### 5.2 Add Entry Screen
```
┌─────────────────────────────────┐
│  Add Milk Entry                 │
├─────────────────────────────────┤
│  Date: [Today ▼]               │
│                                 │
│  Select Customer:               │
│  ┌─────────────────────────┐    │
│  │ ○ Ramesh               │    │
│  │ ● Suresh               │    │
│  │ ○ Priya                │    │
│  └─────────────────────────┘    │
│                                 │
│  Quantity (Litres):             │
│  ┌─────────────────────────┐    │
│  │ [  1.5  ]              │    │
│  └─────────────────────────┘    │
│                                 │
│  Price: ₹55/L                   │
│  Total: ₹82.50                  │
│                                 │
│     [ SAVE ENTRY ]              │
└─────────────────────────────────┘
```

### 5.3 Customers Screen
```
┌─────────────────────────────────┐
│  Customers               [+]   │
├─────────────────────────────────┤
│  ┌─────────────────────────┐    │
│  │ Ramesh        │ 📱 98.. │    │
│  │ 12 entries    │ ✏️ 🗑️   │    │
│  ├─────────────────────────┤    │
│  │ Suresh        │ 📱 78.. │    │
│  │ 8 entries     │ ✏️ 🗑️   │    │
│  ├─────────────────────────┤    │
│  │ Priya         │         │    │
│  │ 15 entries    │ ✏️ 🗑️   │    │
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```

### 5.4 History Screen
```
┌─────────────────────────────────┐
│  History                        │
├─────────────────────────────────┤
│  [ Today ▼]  [ All Customers ▼]│
├─────────────────────────────────┤
│  15 July 2026                   │
│  Ramesh    1.0L   ₹55          │
│  Suresh    1.5L   ₹82          │
│  Priya     0.5L   ₹27          │
│  ─────────────────────────      │
│  Total: 3.0L      ₹165         │
├─────────────────────────────────┤
│  14 July 2026                   │
│  Ramesh    1.0L   ₹55          │
│  Suresh    1.0L   ₹55          │
│  Priya     1.0L   ₹55          │
│  ─────────────────────────      │
│  Total: 3.0L      ₹165         │
└─────────────────────────────────┘
```

### 5.5 Settings Screen
```
┌─────────────────────────────────┐
│  Settings                       │
├─────────────────────────────────┤
│                                 │
│  PRICE                          │
│  Current Price: ₹55/L           │
│  [ Change Price ]               │
│                                 │
│  ─────────────────────────      │
│                                 │
│  DATA                           │
│  [ Backup Data ]                │
│  [ Restore Data ]               │
│  [ Export CSV ]                 │
│                                 │
│  ─────────────────────────      │
│                                 │
│  ABOUT                          │
│  Milk Daily Tracker v1.0        │
│                                 │
└─────────────────────────────────┘
```

---

## 6. Project Structure

```
milk_tracker/
├── lib/
│   ├── main.dart                    # App entry, routes, theme
│   │
│   ├── models/
│   │   ├── customer.dart            # Customer data class
│   │   ├── milk_entry.dart          # MilkEntry data class
│   │   └── price.dart               # Price data class
│   │
│   ├── database/
│   │   └── database_helper.dart     # SQLite operations
│   │
│   ├── screens/
│   │   ├── home_screen.dart         # Today's entries + summary
│   │   ├── add_entry_screen.dart    # Add milk entry form
│   │   ├── customers_screen.dart    # Customer management
│   │   ├── add_customer_screen.dart # Add/edit customer form
│   │   ├── history_screen.dart      # Past entries view
│   │   └── settings_screen.dart     # Price + backup settings
│   │
│   └── utils/
│       └── backup_helper.dart       # Backup/restore utilities
│
├── pubspec.yaml
├── prd.md
└── design.md
```

---

## 7. Key Design Decisions

### 7.1 Price Snapshot Strategy
- When creating an entry, copy current price INTO the entry
- This preserves historical accuracy even if price changes later
- Price table tracks when prices were effective

### 7.2 Date Handling
- Store dates as ISO 8601 strings (YYYY-MM-DD)
- Use UTC to avoid timezone issues
- App displays in local time

### 7.3 Data Consistency
- Foreign key constraints enforced
- Transactions for multi-step operations
- WAL mode for better concurrent read performance

### 7.4 Backup Strategy
- Export: Copy database file to user-accessible location
- Import: User selects file, app replaces database
- Share: Use share_plus to send backup file

---

## 8. Error Handling

| Scenario | Handling |
|----------|----------|
| Database corruption | Prompt restore from backup |
| No customers exist | Show "Add Customer" prompt |
| No price set | Require price setup before entries |
| Backup fails | Show error with retry option |
| Invalid input | Inline validation messages |

---

## 9. Testing Strategy

- Manual testing on Android device/emulator
- Test cases:
  1. Add customer → appears in list
  2. Add entry → shows on home, deducted from customer list
  3. Change price → new entries use new price, old unchanged
  4. Backup → restore → all data intact
  5. Delete customer → entries preserved, customer deactivated
  6. App kill → reopen → all data persists
