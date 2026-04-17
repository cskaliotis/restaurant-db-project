# Restaurant Database Management System

Database project for our DBMS class. Models a multi-location restaurant system with employees, menus, reservations, visits, orders, billing, and payments.

## ERD Overview

- **19 tables** covering restaurants, customers, employees (with disjoint specialization), dining rooms/tables, menus, reservations, visits, orders, billing, and payments
- **574 rows** of sample data

## How to Run

### Option 1: MySQL Terminal
```bash
mysql -u root -p < restaurant_db.sql
```

### Option 2: VS Code (MariaDB extension)
1. Open `restaurant_db.sql` in VS Code
2. Connect to your MariaDB/MySQL server
3. Run the full file to create the database and load data
4. Highlight individual queries from Sections 4–13 and run them to see results

## What's Covered

| Section | Topic |
|---------|-------|
| 1 | CREATE DATABASE, CREATE TABLE (PK, FK, UNIQUE, CHECK, DEFAULT, ENUM) |
| 2 | INSERT statements (574 rows across 19 tables) |
| 3 | Verification query (row counts) |
| 4 | All JOIN types: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF, NATURAL, Multi-table |
| 5 | Set operations: UNION, UNION ALL, INTERSECT, EXCEPT |
| 6 | Subqueries: scalar, IN, EXISTS, correlated, derived table |
| 7 | Aggregates & GROUP BY / HAVING (SUM, COUNT, AVG, MIN, MAX) |
| 8 | Window functions: RANK, DENSE_RANK, ROW_NUMBER, running SUM |
| 9 | CTEs (Common Table Expressions) |
| 10 | CASE expressions |
| 11 | UPDATE & DELETE |
| 12 | Views (CREATE VIEW) |
| 13 | Complex queries: receipts, cook assignments, ROLLUP |

## Files

- `restaurant_db.sql` — Complete self-contained SQL script (run this)
- `csvs/` — Raw data as CSV files (for reference, not needed to run)
