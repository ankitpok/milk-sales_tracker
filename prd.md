# Product Requirements Document (PRD)
## Milk Daily Tracker

### 1. Product Overview
A simple, offline-first mobile application to help track daily milk sales to individual customers. The app enables quick daily entry of who took milk and how much, with reliable local data storage and backup capability.

### 2. Target User
- **Primary User:** Milk seller (single phone, single operator)
- **Customers:** ~3 daily individual buyers
- **Technical Proficiency:** Basic smartphone user

### 3. Core Features

#### 3.1 Customer Management
- Add new customer (name, optional phone number)
- Edit customer details
- Remove/deactivate customer
- View customer list

#### 3.2 Daily Milk Entry
- Select date (defaults to today)
- Select customer from list
- Enter quantity in litres (supports decimals, e.g., 0.5L, 1.5L)
- Submit entry
- View/edit/delete today's entries

#### 3.3 Price Management
- Set current price per litre
- Change price over time (price history preserved)
- Display price used for each historical entry

#### 3.4 History
- View past entries by date
- View entries by customer
- See daily summary (total litres sold per day)

#### 3.5 Data Backup
- Manual backup to local storage
- Restore from backup file
- Export data as CSV

---

### 4. Data Requirements

#### 4.1 Customer Data
| Field | Type | Required |
|-------|------|----------|
| id | INTEGER | Auto-generated |
| name | TEXT | Yes |
| phone | TEXT | No |
| is_active | BOOLEAN | Yes (default: true) |
| created_at | DATETIME | Auto-generated |

#### 4.2 Milk Entry Data
| Field | Type | Required |
|-------|------|----------|
| id | INTEGER | Auto-generated |
| customer_id | INTEGER | Yes (FK) |
| date | DATE | Yes |
| quantity_litres | REAL | Yes |
| price_per_litre | REAL | Yes (snapshot at time of entry) |
| created_at | DATETIME | Auto-generated |

#### 4.3 Price History
| Field | Type | Required |
|-------|------|----------|
| id | INTEGER | Auto-generated |
| price_per_litre | REAL | Yes |
| effective_from | DATE | Yes |
| effective_to | DATE | No (null = current) |

---

### 5. Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | User can add/edit/delete customers | Must |
| FR-02 | User can record daily milk entry for each customer | Must |
| FR-03 | User can set/change price per litre | Must |
| FR-04 | App stores data locally (offline) | Must |
| FR-05 | User can backup and restore data | Must |
| FR-06 | User can view entries by date | Must |
| FR-07 | User can view entries by customer | Should |
| FR-08 | App shows daily total litres sold | Should |
| FR-09 | Price history is preserved | Must |
| FR-10 | Entries show correct price at time of entry | Must |

---

### 6. Non-Functional Requirements

| Attribute | Requirement |
|-----------|-------------|
| Platform | Android (primary), iOS (stretch) |
| Offline | 100% offline capable |
| Data Integrity | SQLite with ACID compliance |
| Backup | Manual export/import |
| Performance | Instant response (<100ms for all operations) |
| UI | Simple, large buttons, minimal typing |
| Language | English |

---

### 7. Success Criteria
- App can be used daily without internet
- Data survives app restart and phone restart
- User can backup and restore all data
- All entries are accurate and timestamped

---

### 8. Out of Scope (v1)
- Payment tracking
- Monthly/yearly reports
- Multi-user/cloud sync
- SMS/WhatsApp notifications
- Barcode/QR scanning
- Multiple milk types

---

### 9. Future Considerations (v2+)
- Payment tracking
- Daily/weekly/monthly reports
- Cloud backup (Google Drive)
- WhatsApp integration for daily bill
- Multi-device support
