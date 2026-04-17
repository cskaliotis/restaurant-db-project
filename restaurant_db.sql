-- ============================================================================
-- RESTAURANT DATABASE — MariaDB / MySQL
-- Run this entire file in VS Code with the MariaDB driver
-- ============================================================================

DROP DATABASE IF EXISTS restaurant_db;
CREATE DATABASE restaurant_db;
USE restaurant_db;

SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================================
-- SECTION 1: CREATE TABLES
-- ============================================================================

CREATE TABLE restaurant (
    restaurant_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE customer (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    birthday DATE,
    phone VARCHAR(50),
    email VARCHAR(255),
    kind ENUM('regular','vip') NOT NULL DEFAULT 'regular'
) ENGINE=InnoDB;

CREATE TABLE dining_room (
    room_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    name VARCHAR(255),
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id)
) ENGINE=InnoDB;

CREATE TABLE dining_table (
    table_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id BIGINT NOT NULL,
    table_no VARCHAR(50) NOT NULL,
    seats INT NOT NULL CHECK (seats > 0),
    UNIQUE (room_id, table_no),
    FOREIGN KEY (room_id) REFERENCES dining_room(room_id)
) ENGINE=InnoDB;

CREATE TABLE menu (
    menu_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    service ENUM('dinner','lunch','wine') NOT NULL,
    active BOOLEAN DEFAULT TRUE,
    UNIQUE (restaurant_id, service),
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id)
) ENGINE=InnoDB;

CREATE TABLE menu_item (
    item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    menu_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    course ENUM('appetizer','entree','dessert') NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    UNIQUE (menu_id, name),
    FOREIGN KEY (menu_id) REFERENCES menu(menu_id)
) ENGINE=InnoDB;

CREATE TABLE employee (
    employee_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address VARCHAR(255),
    pay_rate DECIMAL(10,2),
    role ENUM('manager','line_cook','wait_staff','dishwasher') NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id)
) ENGINE=InnoDB;

CREATE TABLE manager (
    employee_id BIGINT PRIMARY KEY,
    manages_since DATE,
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;

CREATE TABLE line_cook (
    employee_id BIGINT PRIMARY KEY,
    station VARCHAR(100),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;

CREATE TABLE wait_staff (
    employee_id BIGINT PRIMARY KEY,
    section VARCHAR(100),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;

CREATE TABLE dishwasher (
    employee_id BIGINT PRIMARY KEY,
    shift_note VARCHAR(255),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
) ENGINE=InnoDB;

CREATE TABLE reservation (
    reservation_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT,
    customer_id BIGINT,
    party_size INT,
    reserved_for TIMESTAMP NULL,
    special_notes TEXT,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
) ENGINE=InnoDB;

CREATE TABLE visit (
    visit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    restaurant_id BIGINT,
    customer_id BIGINT,
    reservation_id BIGINT,
    table_id BIGINT,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurant(restaurant_id),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id),
    FOREIGN KEY (table_id) REFERENCES dining_table(table_id)
) ENGINE=InnoDB;

CREATE TABLE visit_server (
    visit_id BIGINT NOT NULL,
    staff_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (visit_id, staff_id),
    FOREIGN KEY (visit_id) REFERENCES visit(visit_id),
    FOREIGN KEY (staff_id) REFERENCES wait_staff(employee_id)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT,
    employee_id BIGINT,
    server_id BIGINT,
    ordered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (visit_id) REFERENCES visit(visit_id)
) ENGINE=InnoDB;

CREATE TABLE order_item (
    order_id BIGINT,
    item_id BIGINT,
    qty INT,
    notes TEXT,
    PRIMARY KEY (order_id, item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_item(item_id)
) ENGINE=InnoDB;

CREATE TABLE cook_assignment (
    order_id BIGINT,
    item_id BIGINT,
    cook_id BIGINT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, item_id, cook_id),
    FOREIGN KEY (order_id, item_id) REFERENCES order_item(order_id, item_id),
    FOREIGN KEY (cook_id) REFERENCES line_cook(employee_id)
) ENGINE=InnoDB;

CREATE TABLE bill (
    bill_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    visit_id BIGINT,
    total DECIMAL(12,2),
    closed_at TIMESTAMP NULL,
    FOREIGN KEY (visit_id) REFERENCES visit(visit_id)
) ENGINE=InnoDB;

CREATE TABLE payment (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    bill_id BIGINT,
    method ENUM('cash','credit','debit','mobile'),
    amount DECIMAL(12,2),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (bill_id) REFERENCES bill(bill_id)
) ENGINE=InnoDB;


-- ============================================================================
-- SECTION 2: INSERT DATA (574 rows)
-- ============================================================================

-- restaurant (5 rows)
INSERT INTO `restaurant` (restaurant_id, name, location) VALUES
    (1, 'The Golden Fork', '123 Main St, Tampa, FL'),
    (2, 'Coastal Bistro', '456 Beach Blvd, Clearwater, FL'),
    (3, 'Urban Eats', '789 Downtown Ave, St. Petersburg, FL'),
    (4, 'Sakura Garden', '321 Cherry Ln, Tampa, FL'),
    (5, 'Fire & Smoke BBQ', '654 Hickory Rd, Brandon, FL');

-- customer (20 rows)
INSERT INTO `customer` (customer_id, name, birthday, phone, email, kind) VALUES
    (1, 'Alice Johnson', '1995-02-01', NULL, 'alice.johnson@email.com', 'regular'),
    (2, 'Bob Martinez', '1998-05-08', '813-555-1001', 'bob.martinez@email.com', 'regular'),
    (3, 'Carol Chen', '1982-03-24', '813-555-1002', 'carol.chen@email.com', 'regular'),
    (4, 'David Kim', '1978-11-24', NULL, 'david.kim@email.com', 'vip'),
    (5, 'Eva Thompson', '1992-02-19', '813-555-1004', 'eva.thompson@email.com', 'regular'),
    (6, 'Frank Wilson', '1988-01-01', '813-555-1005', 'frank.wilson@email.com', 'vip'),
    (7, 'Grace Lee', '1977-04-08', NULL, 'grace.lee@email.com', 'regular'),
    (8, 'Henry Davis', '1991-10-01', '813-555-1007', 'henry.davis@email.com', 'regular'),
    (9, 'Isla Young', '1992-04-23', '813-555-1008', 'isla.young@email.com', 'regular'),
    (10, 'Jack Adams', '1995-12-18', NULL, 'jack.adams@email.com', 'vip'),
    (11, 'Karen Brown', '1988-04-15', '813-555-1010', 'karen.brown@email.com', 'regular'),
    (12, 'Leo Clark', '1993-05-26', '813-555-1011', 'leo.clark@email.com', 'regular'),
    (13, 'Mia Hall', '2002-01-25', NULL, 'mia.hall@email.com', 'vip'),
    (14, 'Nathan King', '2000-03-23', '813-555-1013', 'nathan.king@email.com', 'regular'),
    (15, 'Olivia Wright', '1988-06-09', '813-555-1014', 'olivia.wright@email.com', 'regular'),
    (16, 'Paul Scott', '1979-04-25', NULL, 'paul.scott@email.com', 'regular'),
    (17, 'Quinn Moore', '1985-02-03', '813-555-1016', 'quinn.moore@email.com', 'regular'),
    (18, 'Rosa White', '1987-02-12', '813-555-1017', 'rosa.white@email.com', 'vip'),
    (19, 'Sam Turner', '2002-06-20', NULL, 'sam.turner@email.com', 'regular'),
    (20, 'Tina Garcia', '1983-01-24', '813-555-1019', 'tina.garcia@email.com', 'regular');

-- dining_room (10 rows)
INSERT INTO `dining_room` (room_id, restaurant_id, name) VALUES
    (1, 1, 'Main Hall'),
    (2, 1, 'Patio'),
    (3, 2, 'Private Dining'),
    (4, 2, 'Ocean View'),
    (5, 3, 'Bar Area'),
    (6, 3, 'Garden Room'),
    (7, 4, 'Loft'),
    (8, 4, 'Terrace'),
    (9, 5, 'VIP Lounge'),
    (10, 5, 'Smokehouse');

-- dining_table (28 rows)
INSERT INTO `dining_table` (table_id, room_id, table_no, seats) VALUES
    (1, 1, 'T1-1', 2),
    (2, 1, 'T1-2', 6),
    (3, 1, 'T1-3', 2),
    (4, 2, 'T2-1', 4),
    (5, 2, 'T2-2', 6),
    (6, 2, 'T2-3', 4),
    (7, 3, 'T3-1', 2),
    (8, 3, 'T3-2', 2),
    (9, 3, 'T3-3', 4),
    (10, 4, 'T4-1', 2),
    (11, 4, 'T4-2', 4),
    (12, 4, 'T4-3', 2),
    (13, 5, 'T5-1', 4),
    (14, 5, 'T5-2', 8),
    (15, 5, 'T5-3', 6),
    (16, 6, 'T6-1', 6),
    (17, 6, 'T6-2', 6),
    (18, 7, 'T7-1', 4),
    (19, 7, 'T7-2', 2),
    (20, 8, 'T8-1', 4);
INSERT INTO `dining_table` (table_id, room_id, table_no, seats) VALUES
    (21, 8, 'T8-2', 4),
    (22, 8, 'T8-3', 4),
    (23, 9, 'T9-1', 6),
    (24, 9, 'T9-2', 4),
    (25, 9, 'T9-3', 4),
    (26, 10, 'T10-1', 6),
    (27, 10, 'T10-2', 2),
    (28, 10, 'T10-3', 4);

-- menu (10 rows)
INSERT INTO `menu` (menu_id, restaurant_id, service, active) VALUES
    (1, 1, 'dinner', 1),
    (2, 1, 'lunch', 0),
    (3, 2, 'wine', 1),
    (4, 2, 'lunch', 1),
    (5, 3, 'wine', 0),
    (6, 3, 'lunch', 0),
    (7, 4, 'wine', 1),
    (8, 4, 'lunch', 1),
    (9, 5, 'wine', 1),
    (10, 5, 'lunch', 1);

-- menu_item (50 rows)
INSERT INTO `menu_item` (item_id, menu_id, name, course, price) VALUES
    (1, 1, 'Shrimp Cocktail', 'appetizer', 10.44),
    (2, 1, 'Mozzarella Sticks', 'appetizer', 12.8),
    (3, 1, 'Pad Thai', 'entree', 17.67),
    (4, 1, 'Ribeye Steak', 'entree', 17.84),
    (5, 1, 'Cheesecake', 'dessert', 10.58),
    (6, 2, 'Stuffed Mushrooms', 'appetizer', 11.36),
    (7, 2, 'Nachos', 'appetizer', 10.21),
    (8, 2, 'Ramen Bowl', 'entree', 34.66),
    (9, 2, 'Veggie Burger', 'entree', 14.28),
    (10, 2, 'Crème Brûlée', 'dessert', 11.09),
    (11, 3, 'Mozzarella Sticks', 'appetizer', 12.92),
    (12, 3, 'Spring Rolls', 'appetizer', 9.06),
    (13, 3, 'Ramen Bowl', 'entree', 17.8),
    (14, 3, 'Chicken Parmesan', 'entree', 14.08),
    (15, 3, 'Matcha Cake', 'dessert', 12.83),
    (16, 4, 'Shrimp Cocktail', 'appetizer', 14.21),
    (17, 4, 'Mozzarella Sticks', 'appetizer', 13.83),
    (18, 4, 'Ramen Bowl', 'entree', 29.33),
    (19, 4, 'Pad Thai', 'entree', 28.62),
    (20, 4, 'Key Lime Pie', 'dessert', 9.24);
INSERT INTO `menu_item` (item_id, menu_id, name, course, price) VALUES
    (21, 5, 'Shrimp Cocktail', 'appetizer', 14.58),
    (22, 5, 'Mozzarella Sticks', 'appetizer', 14.3),
    (23, 5, 'Club Sandwich', 'entree', 28.37),
    (24, 5, 'Grilled Salmon', 'entree', 25.73),
    (25, 5, 'Crème Brûlée', 'dessert', 12.57),
    (26, 6, 'Spring Rolls', 'appetizer', 6.52),
    (27, 6, 'Edamame', 'appetizer', 13.9),
    (28, 6, 'Ribeye Steak', 'entree', 31.57),
    (29, 6, 'Club Sandwich', 'entree', 33.58),
    (30, 6, 'Key Lime Pie', 'dessert', 7.77),
    (31, 7, 'Crab Cakes', 'appetizer', 7.49),
    (32, 7, 'Mozzarella Sticks', 'appetizer', 10.75),
    (33, 7, 'Pasta Primavera', 'entree', 37.14),
    (34, 7, 'Chicken Parmesan', 'entree', 36.29),
    (35, 7, 'Mochi Ice Cream', 'dessert', 11.28),
    (36, 8, 'Stuffed Mushrooms', 'appetizer', 9.94),
    (37, 8, 'Soup of the Day', 'appetizer', 10.66),
    (38, 8, 'Ribeye Steak', 'entree', 19.39),
    (39, 8, 'Mahi Mahi', 'entree', 22.11),
    (40, 8, 'Mochi Ice Cream', 'dessert', 10.53);
INSERT INTO `menu_item` (item_id, menu_id, name, course, price) VALUES
    (41, 9, 'Bruschetta', 'appetizer', 12.37),
    (42, 9, 'Calamari', 'appetizer', 6.53),
    (43, 9, 'Ribeye Steak', 'entree', 34.63),
    (44, 9, 'Grilled Salmon', 'entree', 15.7),
    (45, 9, 'Mochi Ice Cream', 'dessert', 8.67),
    (46, 10, 'Crab Cakes', 'appetizer', 10.85),
    (47, 10, 'Edamame', 'appetizer', 12.51),
    (48, 10, 'Club Sandwich', 'entree', 27.83),
    (49, 10, 'Pasta Primavera', 'entree', 19.83),
    (50, 10, 'Churros', 'dessert', 11.84);

-- employee (30 rows)
INSERT INTO `employee` (employee_id, restaurant_id, name, email, phone, address, pay_rate, role) VALUES
    (1, 1, 'Maria Garcia', 'maria.garcia@work.com', '813-555-2001', '109 Palm St', 63808.2, 'manager'),
    (2, 1, 'James Brown', 'james.brown@work.com', '813-555-2002', '430 Palm St', 16.61, 'line_cook'),
    (3, 1, 'Sophia Turner', 'sophia.turner@work.com', '813-555-2003', '65 Oak St', 23.23, 'line_cook'),
    (4, 1, 'Liam Scott', 'liam.scott@work.com', '813-555-2004', '755 Elm St', 12.79, 'wait_staff'),
    (5, 1, 'Emma Davis', 'emma.davis@work.com', '813-555-2005', '121 Pine St', 22.41, 'wait_staff'),
    (6, 1, 'Noah Clark', 'noah.clark@work.com', '813-555-2006', '559 Palm St', 14.49, 'dishwasher'),
    (7, 2, 'Olivia Adams', 'olivia.adams@work.com', '813-555-2007', '197 Elm St', 62803.65, 'manager'),
    (8, 2, 'Ethan Moore', 'ethan.moore@work.com', '813-555-2008', '905 Oak St', 18.01, 'line_cook'),
    (9, 2, 'Ava White', 'ava.white@work.com', '813-555-2009', '892 Maple St', 17.76, 'line_cook'),
    (10, 2, 'Mason Hall', 'mason.hall@work.com', '813-555-2010', '677 Maple St', 13.27, 'wait_staff'),
    (11, 2, 'Isabella Young', 'isabella.young@work.com', '813-555-2011', '105 Pine St', 22.87, 'wait_staff'),
    (12, 2, 'Lucas King', 'lucas.king@work.com', '813-555-2012', '507 Palm St', 14.16, 'dishwasher'),
    (13, 3, 'Mia Wright', 'mia.wright@work.com', '813-555-2013', '420 Oak St', 64274.95, 'manager'),
    (14, 3, 'Benjamin Lee', 'benjamin.lee@work.com', '813-555-2014', '12 Palm St', 14.14, 'line_cook'),
    (15, 3, 'Charlotte Walker', 'charlotte.walker@work.com', '813-555-2015', '812 Palm St', 15.45, 'line_cook'),
    (16, 3, 'Logan Harris', 'logan.harris@work.com', '813-555-2016', '723 Maple St', 15.71, 'wait_staff'),
    (17, 3, 'Amelia Allen', 'amelia.allen@work.com', '813-555-2017', '508 Pine St', 20.6, 'wait_staff'),
    (18, 3, 'Aiden Martin', 'aiden.martin@work.com', '813-555-2018', '232 Oak St', 14.47, 'dishwasher'),
    (19, 4, 'Harper Hill', 'harper.hill@work.com', '813-555-2019', '565 Oak St', 71583.61, 'manager'),
    (20, 4, 'Elijah Thomas', 'elijah.thomas@work.com', '813-555-2020', '68 Oak St', 21.72, 'line_cook');
INSERT INTO `employee` (employee_id, restaurant_id, name, email, phone, address, pay_rate, role) VALUES
    (21, 4, 'Ella Anderson', 'ella.anderson@work.com', '813-555-2021', '524 Maple St', 19.59, 'line_cook'),
    (22, 4, 'Jackson Jackson', 'jackson.jackson@work.com', '813-555-2022', '993 Maple St', 14.05, 'wait_staff'),
    (23, 4, 'Lily Lewis', 'lily.lewis@work.com', '813-555-2023', '200 Oak St', 13.04, 'wait_staff'),
    (24, 4, 'Sebastian Robinson', 'sebastian.robinson@work.com', '813-555-2024', '701 Pine St', 19.74, 'dishwasher'),
    (25, 5, 'Zoe Thompson', 'zoe.thompson@work.com', '813-555-2025', '974 Maple St', 68075.51, 'manager'),
    (26, 5, 'Mateo Perez', 'mateo.perez@work.com', '813-555-2026', '618 Oak St', 15.2, 'line_cook'),
    (27, 5, 'Chloe Gonzalez', 'chloe.gonzalez@work.com', '813-555-2027', '439 Maple St', 20.05, 'line_cook'),
    (28, 5, 'Owen Rivera', 'owen.rivera@work.com', '813-555-2028', '333 Elm St', 19.35, 'wait_staff'),
    (29, 5, 'Penelope Campbell', 'penelope.campbell@work.com', '813-555-2029', '743 Elm St', 14.66, 'wait_staff'),
    (30, 5, 'Daniel Mitchell', 'daniel.mitchell@work.com', '813-555-2030', '415 Pine St', 15.1, 'dishwasher');

-- manager (5 rows)
INSERT INTO `manager` (employee_id, manages_since) VALUES
    (1, '2023-11-10'),
    (7, '2022-10-04'),
    (13, '2019-06-03'),
    (19, '2024-09-23'),
    (25, '2023-09-10');

-- line_cook (10 rows)
INSERT INTO `line_cook` (employee_id, station) VALUES
    (2, 'Prep'),
    (3, 'Fry'),
    (8, 'Grill'),
    (9, 'Wok'),
    (14, 'Sauté'),
    (15, 'Fry'),
    (20, 'Fry'),
    (21, 'Wok'),
    (26, 'Plancha'),
    (27, 'Grill');

-- wait_staff (10 rows)
INSERT INTO `wait_staff` (employee_id, section) VALUES
    (4, 'Main Hall'),
    (5, 'Main Hall'),
    (10, 'Patio'),
    (11, 'Garden'),
    (16, 'Bar'),
    (17, 'Patio'),
    (22, 'Terrace'),
    (23, 'Garden'),
    (28, 'Patio'),
    (29, 'Bar');

-- dishwasher (5 rows)
INSERT INTO `dishwasher` (employee_id, shift_note) VALUES
    (6, 'Weekend only'),
    (12, 'Double shift'),
    (18, 'Weekend only'),
    (24, 'Morning shift'),
    (30, 'Morning shift');

-- reservation (15 rows)
INSERT INTO `reservation` (reservation_id, restaurant_id, customer_id, party_size, reserved_for, special_notes) VALUES
    (1, 1, 18, 3, '2025-04-14 19:00:00', NULL),
    (2, 2, 11, 4, '2025-04-20 19:00:00', 'High chair needed'),
    (3, 4, 9, 1, '2025-04-11 20:00:00', 'Birthday celebration'),
    (4, 1, 1, 6, '2025-04-22 18:00:00', 'Birthday celebration'),
    (5, 2, 15, 7, '2025-04-18 17:00:00', NULL),
    (6, 1, 5, 1, '2025-04-23 19:00:00', NULL),
    (7, 5, 5, 7, '2025-04-12 17:00:00', 'Birthday celebration'),
    (8, 3, 2, 6, '2025-04-13 18:00:00', NULL),
    (9, 3, 18, 7, '2025-04-19 18:00:00', 'Anniversary dinner'),
    (10, 2, 6, 7, '2025-04-10 18:00:00', 'Allergic to shellfish'),
    (11, 4, 8, 5, '2025-04-12 17:00:00', 'Vegetarian options needed'),
    (12, 1, 16, 4, '2025-04-13 20:00:00', 'Allergic to shellfish'),
    (13, 3, 8, 4, '2025-04-10 18:00:00', 'Vegetarian options needed'),
    (14, 3, 9, 2, '2025-04-22 19:00:00', 'Allergic to shellfish'),
    (15, 5, 13, 6, '2025-04-10 17:00:00', 'Birthday celebration');

-- visit (30 rows)
INSERT INTO `visit` (visit_id, restaurant_id, customer_id, reservation_id, table_id, started_at, ended_at) VALUES
    (1, 1, 18, 1, 2, '2025-04-28 19:02:00', '2025-04-28 20:40:00'),
    (2, 2, 11, 2, 10, '2025-04-21 22:50:00', '2025-04-22 01:17:00'),
    (3, 4, 9, 3, 22, '2025-04-26 17:24:00', '2025-04-26 20:36:00'),
    (4, 1, 1, 4, 3, '2025-04-11 22:27:00', '2025-04-12 00:00:00'),
    (5, 2, 15, 5, 11, '2025-04-16 19:27:00', '2025-04-16 21:09:00'),
    (6, 1, 5, 6, 3, '2025-04-29 19:42:00', '2025-04-29 21:01:00'),
    (7, 5, 5, 7, 27, '2025-04-19 22:26:00', '2025-04-20 00:51:00'),
    (8, 3, 2, 8, 15, '2025-04-27 18:12:00', '2025-04-27 20:54:00'),
    (9, 3, 18, 9, 16, '2025-04-15 21:36:00', '2025-04-16 00:01:00'),
    (10, 2, 6, 10, 11, '2025-04-10 19:18:00', '2025-04-10 20:45:00'),
    (11, 4, 8, 11, 22, '2025-04-29 22:20:00', '2025-04-30 00:48:00'),
    (12, 1, 16, 12, 4, '2025-04-16 21:30:00', '2025-04-17 00:40:00'),
    (13, 1, NULL, NULL, 1, '2025-04-17 22:19:00', '2025-04-17 23:31:00'),
    (14, 2, 1, NULL, 8, '2025-04-25 21:54:00', '2025-04-25 23:23:00'),
    (15, 4, 19, NULL, 21, '2025-04-25 20:15:00', '2025-04-25 21:56:00'),
    (16, 1, NULL, NULL, 2, '2025-04-15 22:33:00', '2025-04-16 00:36:00'),
    (17, 5, 8, NULL, 26, '2025-04-14 20:42:00', '2025-04-15 00:17:00'),
    (18, 5, NULL, NULL, 27, '2025-04-26 20:53:00', '2025-04-27 00:21:00'),
    (19, 2, NULL, NULL, 9, '2025-04-17 22:17:00', '2025-04-18 01:48:00'),
    (20, 2, NULL, NULL, 7, '2025-04-19 18:17:00', '2025-04-19 20:37:00');
INSERT INTO `visit` (visit_id, restaurant_id, customer_id, reservation_id, table_id, started_at, ended_at) VALUES
    (21, 5, 3, NULL, 24, '2025-04-17 20:44:00', '2025-04-17 22:29:00'),
    (22, 2, NULL, NULL, 10, '2025-04-20 21:29:00', '2025-04-20 23:32:00'),
    (23, 2, NULL, NULL, 11, '2025-04-10 21:24:00', '2025-04-10 23:24:00'),
    (24, 3, NULL, NULL, 16, '2025-04-27 22:47:00', '2025-04-28 02:25:00'),
    (25, 2, 16, NULL, 9, '2025-04-23 20:01:00', '2025-04-23 22:22:00'),
    (26, 4, NULL, NULL, 19, '2025-04-29 21:01:00', '2025-04-29 23:38:00'),
    (27, 5, 1, NULL, 28, '2025-04-23 18:55:00', '2025-04-23 21:06:00'),
    (28, 1, NULL, NULL, 3, '2025-04-16 20:20:00', NULL),
    (29, 3, NULL, NULL, 13, '2025-04-25 17:47:00', NULL),
    (30, 3, 8, NULL, 13, '2025-04-10 18:12:00', NULL);

-- visit_server (30 rows)
INSERT INTO `visit_server` (visit_id, staff_id, assigned_at) VALUES
    (1, 4, '2025-04-28 19:02:00'),
    (2, 10, '2025-04-21 22:50:00'),
    (3, 22, '2025-04-26 17:24:00'),
    (4, 5, '2025-04-11 22:27:00'),
    (5, 10, '2025-04-16 19:27:00'),
    (6, 4, '2025-04-29 19:42:00'),
    (7, 29, '2025-04-19 22:26:00'),
    (8, 17, '2025-04-27 18:12:00'),
    (9, 17, '2025-04-15 21:36:00'),
    (10, 10, '2025-04-10 19:18:00'),
    (11, 22, '2025-04-29 22:20:00'),
    (12, 4, '2025-04-16 21:30:00'),
    (13, 5, '2025-04-17 22:19:00'),
    (14, 10, '2025-04-25 21:54:00'),
    (15, 22, '2025-04-25 20:15:00'),
    (16, 5, '2025-04-15 22:33:00'),
    (17, 29, '2025-04-14 20:42:00'),
    (18, 29, '2025-04-26 20:53:00'),
    (19, 10, '2025-04-17 22:17:00'),
    (20, 10, '2025-04-19 18:17:00');
INSERT INTO `visit_server` (visit_id, staff_id, assigned_at) VALUES
    (21, 28, '2025-04-17 20:44:00'),
    (22, 10, '2025-04-20 21:29:00'),
    (23, 11, '2025-04-10 21:24:00'),
    (24, 16, '2025-04-27 22:47:00'),
    (25, 10, '2025-04-23 20:01:00'),
    (26, 23, '2025-04-29 21:01:00'),
    (27, 29, '2025-04-23 18:55:00'),
    (28, 5, '2025-04-16 20:20:00'),
    (29, 16, '2025-04-25 17:47:00'),
    (30, 17, '2025-04-10 18:12:00');

-- orders (38 rows)
INSERT INTO `orders` (order_id, visit_id, employee_id, server_id, ordered_at) VALUES
    (1, 1, 4, 4, '2025-04-28 19:22:00'),
    (2, 1, 4, 4, '2025-04-28 19:10:00'),
    (3, 2, 11, 11, '2025-04-21 23:15:00'),
    (4, 3, 23, 23, '2025-04-26 17:42:00'),
    (5, 4, 4, 4, '2025-04-11 22:51:00'),
    (6, 5, 11, 11, '2025-04-16 19:45:00'),
    (7, 5, 11, 11, '2025-04-16 19:55:00'),
    (8, 6, 5, 5, '2025-04-29 19:54:00'),
    (9, 7, 28, 28, '2025-04-19 22:45:00'),
    (10, 8, 16, 16, '2025-04-27 18:35:00'),
    (11, 8, 16, 16, '2025-04-27 18:36:00'),
    (12, 9, 17, 17, '2025-04-15 21:41:00'),
    (13, 10, 11, 11, '2025-04-10 19:28:00'),
    (14, 11, 23, 23, '2025-04-29 22:36:00'),
    (15, 12, 5, 5, '2025-04-16 21:43:00'),
    (16, 13, 5, 5, '2025-04-17 22:40:00'),
    (17, 14, 10, 10, '2025-04-25 22:06:00'),
    (18, 15, 23, 23, '2025-04-25 20:37:00'),
    (19, 15, 23, 23, '2025-04-25 20:44:00'),
    (20, 16, 4, 4, '2025-04-15 22:58:00');
INSERT INTO `orders` (order_id, visit_id, employee_id, server_id, ordered_at) VALUES
    (21, 16, 4, 4, '2025-04-15 23:00:00'),
    (22, 17, 29, 29, '2025-04-14 21:12:00'),
    (23, 17, 29, 29, '2025-04-14 20:47:00'),
    (24, 18, 28, 28, '2025-04-26 21:05:00'),
    (25, 19, 11, 11, '2025-04-17 22:31:00'),
    (26, 20, 11, 11, '2025-04-19 18:39:00'),
    (27, 20, 11, 11, '2025-04-19 18:38:00'),
    (28, 21, 29, 29, '2025-04-17 21:12:00'),
    (29, 21, 29, 29, '2025-04-17 21:06:00'),
    (30, 22, 11, 11, '2025-04-20 21:56:00'),
    (31, 23, 11, 11, '2025-04-10 21:38:00'),
    (32, 24, 17, 17, '2025-04-27 22:55:00'),
    (33, 25, 10, 10, '2025-04-23 20:09:00'),
    (34, 26, 22, 22, '2025-04-29 21:12:00'),
    (35, 27, 29, 29, '2025-04-23 19:23:00'),
    (36, 28, 5, 5, '2025-04-16 20:31:00'),
    (37, 29, 17, 17, '2025-04-25 18:03:00'),
    (38, 30, 16, 16, '2025-04-10 18:17:00');

-- order_item (111 rows)
INSERT INTO `order_item` (order_id, item_id, qty, notes) VALUES
    (1, 5, 1, 'Extra butter'),
    (1, 1, 1, 'Light sauce'),
    (2, 8, 1, 'Gluten free'),
    (2, 2, 1, 'Extra spicy'),
    (3, 18, 1, 'No sauce'),
    (3, 16, 2, NULL),
    (3, 13, 1, 'No skin'),
    (3, 11, 2, NULL),
    (4, 33, 1, 'Blackened'),
    (5, 2, 2, 'Blackened'),
    (5, 4, 2, 'Gluten free'),
    (5, 10, 2, 'Blackened'),
    (6, 19, 2, 'Add avocado'),
    (6, 17, 2, 'Medium rare'),
    (7, 15, 1, 'No onions'),
    (7, 11, 1, 'Medium rare'),
    (7, 12, 3, NULL),
    (7, 17, 1, NULL),
    (8, 9, 1, NULL),
    (8, 2, 2, 'Extra spicy');
INSERT INTO `order_item` (order_id, item_id, qty, notes) VALUES
    (9, 45, 3, 'Medium rare'),
    (9, 41, 3, 'No sauce'),
    (9, 44, 2, NULL),
    (9, 43, 3, NULL),
    (10, 30, 1, 'Extra butter'),
    (10, 24, 1, 'No onions'),
    (10, 27, 1, 'Add avocado'),
    (11, 23, 1, 'Blackened'),
    (11, 22, 1, 'Gluten free'),
    (11, 21, 3, 'No sauce'),
    (12, 28, 3, 'Medium rare'),
    (12, 22, 3, 'No skin'),
    (12, 30, 1, 'Extra butter'),
    (13, 18, 3, 'Well done'),
    (13, 12, 2, 'Medium rare'),
    (13, 11, 1, NULL),
    (13, 14, 1, 'No onions'),
    (14, 35, 2, NULL),
    (15, 8, 3, 'Extra spicy'),
    (15, 9, 1, NULL);
INSERT INTO `order_item` (order_id, item_id, qty, notes) VALUES
    (16, 8, 2, 'Well done'),
    (16, 2, 1, 'No onions'),
    (16, 10, 1, 'No sauce'),
    (16, 3, 1, 'Well done'),
    (17, 18, 2, NULL),
    (17, 15, 2, NULL),
    (17, 17, 1, 'Medium rare'),
    (17, 20, 1, NULL),
    (18, 39, 1, NULL),
    (18, 31, 2, 'Well done'),
    (18, 38, 2, 'Blackened'),
    (18, 34, 2, 'No onions'),
    (19, 31, 1, 'Add avocado'),
    (19, 34, 1, 'Extra spicy'),
    (19, 35, 3, 'Extra spicy'),
    (19, 38, 1, NULL),
    (20, 3, 2, NULL),
    (20, 5, 2, 'No skin'),
    (21, 4, 1, 'Extra spicy'),
    (22, 43, 2, 'Add avocado');
INSERT INTO `order_item` (order_id, item_id, qty, notes) VALUES
    (23, 49, 2, 'Extra spicy'),
    (23, 45, 1, 'Extra spicy'),
    (23, 47, 2, NULL),
    (24, 44, 1, 'Medium rare'),
    (24, 49, 2, 'Well done'),
    (24, 43, 2, 'Medium rare'),
    (24, 47, 1, 'Medium rare'),
    (25, 20, 2, 'Extra butter'),
    (25, 18, 2, 'Well done'),
    (25, 13, 1, 'Extra butter'),
    (26, 18, 1, 'Gluten free'),
    (26, 16, 2, NULL),
    (26, 14, 2, NULL),
    (26, 19, 1, 'Light sauce'),
    (27, 17, 1, NULL),
    (27, 20, 2, 'Gluten free'),
    (27, 13, 1, 'No sauce'),
    (27, 14, 1, 'No sauce'),
    (28, 42, 3, NULL),
    (28, 49, 2, 'No sauce');
INSERT INTO `order_item` (order_id, item_id, qty, notes) VALUES
    (28, 48, 3, NULL),
    (28, 41, 1, 'Extra spicy'),
    (29, 46, 1, 'No sauce'),
    (29, 47, 3, 'No sauce'),
    (29, 42, 2, 'No skin'),
    (30, 18, 2, NULL),
    (30, 19, 1, 'No onions'),
    (30, 11, 3, 'Add avocado'),
    (31, 14, 1, 'Blackened'),
    (31, 12, 3, 'Light sauce'),
    (31, 17, 1, 'Extra spicy'),
    (32, 25, 1, 'Well done'),
    (32, 21, 1, 'Medium rare'),
    (33, 16, 1, 'Extra butter'),
    (33, 17, 2, 'Gluten free'),
    (33, 13, 3, 'Blackened'),
    (34, 33, 1, 'Gluten free'),
    (34, 40, 2, 'Gluten free'),
    (35, 48, 1, 'Extra spicy'),
    (35, 43, 3, 'Medium rare');
INSERT INTO `order_item` (order_id, item_id, qty, notes) VALUES
    (36, 5, 3, 'Extra butter'),
    (36, 1, 1, NULL),
    (36, 8, 2, 'Well done'),
    (36, 3, 2, 'Medium rare'),
    (37, 25, 2, 'No sauce'),
    (37, 28, 2, NULL),
    (37, 30, 1, 'No skin'),
    (37, 22, 2, 'Well done'),
    (38, 25, 1, NULL),
    (38, 21, 2, 'No sauce'),
    (38, 27, 3, 'Blackened');

-- cook_assignment (111 rows)
INSERT INTO `cook_assignment` (order_id, item_id, cook_id, assigned_at) VALUES
    (1, 5, 2, '2025-04-28 19:27:00'),
    (1, 1, 3, '2025-04-28 19:25:00'),
    (2, 8, 2, '2025-04-28 19:15:00'),
    (2, 2, 3, '2025-04-28 19:12:00'),
    (3, 18, 8, '2025-04-21 23:20:00'),
    (3, 16, 9, '2025-04-21 23:17:00'),
    (3, 13, 8, '2025-04-21 23:16:00'),
    (3, 11, 9, '2025-04-21 23:19:00'),
    (4, 33, 20, '2025-04-26 17:47:00'),
    (5, 2, 3, '2025-04-11 22:53:00'),
    (5, 4, 2, '2025-04-11 22:54:00'),
    (5, 10, 3, '2025-04-11 22:55:00'),
    (6, 19, 8, '2025-04-16 19:47:00'),
    (6, 17, 8, '2025-04-16 19:50:00'),
    (7, 15, 9, '2025-04-16 20:00:00'),
    (7, 11, 9, '2025-04-16 19:57:00'),
    (7, 12, 9, '2025-04-16 19:59:00'),
    (7, 17, 9, '2025-04-16 19:58:00'),
    (8, 9, 2, '2025-04-29 19:58:00'),
    (8, 2, 2, '2025-04-29 19:56:00');
INSERT INTO `cook_assignment` (order_id, item_id, cook_id, assigned_at) VALUES
    (9, 45, 26, '2025-04-19 22:49:00'),
    (9, 41, 27, '2025-04-19 22:46:00'),
    (9, 44, 27, '2025-04-19 22:46:00'),
    (9, 43, 27, '2025-04-19 22:50:00'),
    (10, 30, 14, '2025-04-27 18:39:00'),
    (10, 24, 15, '2025-04-27 18:38:00'),
    (10, 27, 15, '2025-04-27 18:38:00'),
    (11, 23, 14, '2025-04-27 18:38:00'),
    (11, 22, 15, '2025-04-27 18:37:00'),
    (11, 21, 15, '2025-04-27 18:41:00'),
    (12, 28, 14, '2025-04-15 21:42:00'),
    (12, 22, 15, '2025-04-15 21:44:00'),
    (12, 30, 15, '2025-04-15 21:42:00'),
    (13, 18, 8, '2025-04-10 19:29:00'),
    (13, 12, 8, '2025-04-10 19:31:00'),
    (13, 11, 9, '2025-04-10 19:29:00'),
    (13, 14, 8, '2025-04-10 19:30:00'),
    (14, 35, 20, '2025-04-29 22:40:00'),
    (15, 8, 3, '2025-04-16 21:46:00'),
    (15, 9, 3, '2025-04-16 21:48:00');
INSERT INTO `cook_assignment` (order_id, item_id, cook_id, assigned_at) VALUES
    (16, 8, 2, '2025-04-17 22:44:00'),
    (16, 2, 2, '2025-04-17 22:44:00'),
    (16, 10, 3, '2025-04-17 22:43:00'),
    (16, 3, 2, '2025-04-17 22:43:00'),
    (17, 18, 8, '2025-04-25 22:10:00'),
    (17, 15, 9, '2025-04-25 22:08:00'),
    (17, 17, 9, '2025-04-25 22:07:00'),
    (17, 20, 9, '2025-04-25 22:11:00'),
    (18, 39, 21, '2025-04-25 20:38:00'),
    (18, 31, 21, '2025-04-25 20:40:00'),
    (18, 38, 20, '2025-04-25 20:38:00'),
    (18, 34, 21, '2025-04-25 20:38:00'),
    (19, 31, 20, '2025-04-25 20:49:00'),
    (19, 34, 20, '2025-04-25 20:45:00'),
    (19, 35, 21, '2025-04-25 20:46:00'),
    (19, 38, 20, '2025-04-25 20:49:00'),
    (20, 3, 2, '2025-04-15 22:59:00'),
    (20, 5, 2, '2025-04-15 23:03:00'),
    (21, 4, 2, '2025-04-15 23:02:00'),
    (22, 43, 27, '2025-04-14 21:14:00');
INSERT INTO `cook_assignment` (order_id, item_id, cook_id, assigned_at) VALUES
    (23, 49, 26, '2025-04-14 20:50:00'),
    (23, 45, 26, '2025-04-14 20:49:00'),
    (23, 47, 27, '2025-04-14 20:49:00'),
    (24, 44, 26, '2025-04-26 21:06:00'),
    (24, 49, 26, '2025-04-26 21:06:00'),
    (24, 43, 27, '2025-04-26 21:07:00'),
    (24, 47, 27, '2025-04-26 21:06:00'),
    (25, 20, 8, '2025-04-17 22:34:00'),
    (25, 18, 8, '2025-04-17 22:33:00'),
    (25, 13, 9, '2025-04-17 22:36:00'),
    (26, 18, 8, '2025-04-19 18:40:00'),
    (26, 16, 9, '2025-04-19 18:43:00'),
    (26, 14, 9, '2025-04-19 18:44:00'),
    (26, 19, 8, '2025-04-19 18:43:00'),
    (27, 17, 8, '2025-04-19 18:43:00'),
    (27, 20, 8, '2025-04-19 18:43:00'),
    (27, 13, 9, '2025-04-19 18:42:00'),
    (27, 14, 8, '2025-04-19 18:39:00'),
    (28, 42, 27, '2025-04-17 21:16:00'),
    (28, 49, 27, '2025-04-17 21:13:00');
INSERT INTO `cook_assignment` (order_id, item_id, cook_id, assigned_at) VALUES
    (28, 48, 27, '2025-04-17 21:16:00'),
    (28, 41, 26, '2025-04-17 21:13:00'),
    (29, 46, 27, '2025-04-17 21:11:00'),
    (29, 47, 26, '2025-04-17 21:07:00'),
    (29, 42, 26, '2025-04-17 21:09:00'),
    (30, 18, 9, '2025-04-20 22:00:00'),
    (30, 19, 9, '2025-04-20 22:00:00'),
    (30, 11, 9, '2025-04-20 21:57:00'),
    (31, 14, 8, '2025-04-10 21:43:00'),
    (31, 12, 8, '2025-04-10 21:42:00'),
    (31, 17, 9, '2025-04-10 21:40:00'),
    (32, 25, 15, '2025-04-27 22:58:00'),
    (32, 21, 15, '2025-04-27 22:59:00'),
    (33, 16, 9, '2025-04-23 20:10:00'),
    (33, 17, 9, '2025-04-23 20:13:00'),
    (33, 13, 9, '2025-04-23 20:12:00'),
    (34, 33, 21, '2025-04-29 21:14:00'),
    (34, 40, 21, '2025-04-29 21:13:00'),
    (35, 48, 26, '2025-04-23 19:24:00'),
    (35, 43, 26, '2025-04-23 19:27:00');
INSERT INTO `cook_assignment` (order_id, item_id, cook_id, assigned_at) VALUES
    (36, 5, 2, '2025-04-16 20:34:00'),
    (36, 1, 2, '2025-04-16 20:36:00'),
    (36, 8, 2, '2025-04-16 20:36:00'),
    (36, 3, 3, '2025-04-16 20:32:00'),
    (37, 25, 15, '2025-04-25 18:06:00'),
    (37, 28, 15, '2025-04-25 18:04:00'),
    (37, 30, 15, '2025-04-25 18:08:00'),
    (37, 22, 15, '2025-04-25 18:06:00'),
    (38, 25, 14, '2025-04-10 18:22:00'),
    (38, 21, 14, '2025-04-10 18:19:00'),
    (38, 27, 15, '2025-04-10 18:19:00');

-- bill (25 rows)
INSERT INTO `bill` (bill_id, visit_id, total, closed_at) VALUES
    (1, 1, 68.48, '2025-04-28 20:40:00'),
    (2, 2, 101.39, '2025-04-22 01:17:00'),
    (3, 3, 37.14, '2025-04-26 20:36:00'),
    (4, 4, 83.46, '2025-04-12 00:00:00'),
    (5, 5, 151.66, '2025-04-16 21:09:00'),
    (6, 6, 39.88, '2025-04-29 21:01:00'),
    (7, 7, 198.41, '2025-04-20 00:51:00'),
    (8, 8, 133.81, '2025-04-27 20:54:00'),
    (9, 9, 145.38, '2025-04-16 00:01:00'),
    (10, 11, 22.56, '2025-04-30 00:48:00'),
    (11, 12, 118.26, '2025-04-17 00:40:00'),
    (12, 14, 107.39, '2025-04-25 23:23:00'),
    (13, 15, 245.46, '2025-04-25 21:56:00'),
    (14, 16, 74.34, '2025-04-16 00:36:00'),
    (15, 18, 137.13, '2025-04-27 00:21:00'),
    (16, 19, 94.94, '2025-04-18 01:48:00'),
    (17, 20, 178.72, '2025-04-19 20:37:00'),
    (18, 21, 216.55, '2025-04-17 22:29:00'),
    (19, 23, 55.09, '2025-04-10 23:24:00'),
    (20, 24, 27.15, '2025-04-28 02:25:00');
INSERT INTO `bill` (bill_id, visit_id, total, closed_at) VALUES
    (21, 26, 58.2, '2025-04-29 23:38:00'),
    (22, 27, 131.72, '2025-04-23 21:06:00'),
    (23, 28, 146.84, NULL),
    (24, 29, 124.65, NULL),
    (25, 30, 83.43, NULL);

-- payment (31 rows)
INSERT INTO `payment` (payment_id, bill_id, method, amount, paid_at) VALUES
    (1, 1, 'mobile', 68.48, '2025-04-28 20:40:00'),
    (2, 2, 'cash', 60.47, '2025-04-22 01:17:00'),
    (3, 2, 'cash', 40.92, '2025-04-22 01:17:00'),
    (4, 3, 'credit', 37.14, '2025-04-26 20:36:00'),
    (5, 4, 'mobile', 83.46, '2025-04-12 00:00:00'),
    (6, 5, 'debit', 151.66, '2025-04-16 21:09:00'),
    (7, 6, 'debit', 39.88, '2025-04-29 21:01:00'),
    (8, 7, 'cash', 198.41, '2025-04-20 00:51:00'),
    (9, 8, 'credit', 133.81, '2025-04-27 20:54:00'),
    (10, 9, 'cash', 79.54, '2025-04-16 00:01:00'),
    (11, 9, 'debit', 65.84, '2025-04-16 00:01:00'),
    (12, 10, 'mobile', 22.56, '2025-04-30 00:48:00'),
    (13, 11, 'mobile', 118.26, '2025-04-17 00:40:00'),
    (14, 12, 'credit', 107.39, '2025-04-25 23:23:00'),
    (15, 13, 'cash', 245.46, '2025-04-25 21:56:00'),
    (16, 14, 'cash', 74.34, '2025-04-16 00:36:00'),
    (17, 15, 'mobile', 137.13, '2025-04-27 00:21:00'),
    (18, 16, 'debit', 94.94, '2025-04-18 01:48:00'),
    (19, 17, 'cash', 81.87, '2025-04-19 20:37:00'),
    (20, 17, 'cash', 96.85, '2025-04-19 20:37:00');
INSERT INTO `payment` (payment_id, bill_id, method, amount, paid_at) VALUES
    (21, 18, 'credit', 216.55, '2025-04-17 22:29:00'),
    (22, 19, 'debit', 55.09, '2025-04-10 23:24:00'),
    (23, 20, 'cash', 27.15, '2025-04-28 02:25:00'),
    (24, 21, 'credit', 34.85, '2025-04-29 23:38:00'),
    (25, 21, 'credit', 23.35, '2025-04-29 23:38:00'),
    (26, 22, 'credit', 131.72, '2025-04-23 21:06:00'),
    (27, 23, 'debit', 146.84, '2025-04-15 00:00:00'),
    (28, 24, 'cash', 80.36, '2025-04-15 00:00:00'),
    (29, 24, 'mobile', 44.29, '2025-04-15 00:00:00'),
    (30, 25, 'debit', 55.77, '2025-04-15 00:00:00'),
    (31, 25, 'mobile', 27.66, '2025-04-15 00:00:00');

SET FOREIGN_KEY_CHECKS = 1;


-- ============================================================================
-- SECTION 3: VERIFY DATA LOADED
-- ============================================================================

SELECT 'restaurant'      AS tbl, COUNT(*) AS rows_loaded FROM restaurant
UNION ALL SELECT 'customer',        COUNT(*) FROM customer
UNION ALL SELECT 'dining_room',     COUNT(*) FROM dining_room
UNION ALL SELECT 'dining_table',    COUNT(*) FROM dining_table
UNION ALL SELECT 'menu',            COUNT(*) FROM menu
UNION ALL SELECT 'menu_item',       COUNT(*) FROM menu_item
UNION ALL SELECT 'employee',        COUNT(*) FROM employee
UNION ALL SELECT 'manager',         COUNT(*) FROM manager
UNION ALL SELECT 'line_cook',       COUNT(*) FROM line_cook
UNION ALL SELECT 'wait_staff',      COUNT(*) FROM wait_staff
UNION ALL SELECT 'dishwasher',      COUNT(*) FROM dishwasher
UNION ALL SELECT 'reservation',     COUNT(*) FROM reservation
UNION ALL SELECT 'visit',           COUNT(*) FROM visit
UNION ALL SELECT 'visit_server',    COUNT(*) FROM visit_server
UNION ALL SELECT 'orders',          COUNT(*) FROM orders
UNION ALL SELECT 'order_item',      COUNT(*) FROM order_item
UNION ALL SELECT 'cook_assignment', COUNT(*) FROM cook_assignment
UNION ALL SELECT 'bill',            COUNT(*) FROM bill
UNION ALL SELECT 'payment',         COUNT(*) FROM payment;


-- ============================================================================
-- SECTION 4: ALL JOIN TYPES
-- ============================================================================

-- 4a. INNER JOIN — Orders with their server and restaurant
SELECT
    o.order_id,
    e.name          AS server_name,
    r.name          AS restaurant_name,
    o.ordered_at
FROM orders o
INNER JOIN employee e   ON e.employee_id   = o.server_id
INNER JOIN visit v      ON v.visit_id      = o.visit_id
INNER JOIN restaurant r ON r.restaurant_id = v.restaurant_id
ORDER BY o.ordered_at;

-- 4b. LEFT JOIN — All customers with their reservations (no-reservation customers still show)
SELECT
    c.customer_id,
    c.name          AS customer_name,
    c.kind,
    res.reservation_id,
    res.reserved_for,
    res.party_size
FROM customer c
LEFT JOIN reservation res ON res.customer_id = c.customer_id
ORDER BY c.name, res.reserved_for;

-- 4c. RIGHT JOIN — All tables and any visits (unused tables still show)
SELECT
    dt.table_id,
    dt.table_no,
    dr.name   AS room,
    v.visit_id,
    v.started_at
FROM visit v
RIGHT JOIN dining_table dt ON dt.table_id = v.table_id
RIGHT JOIN dining_room dr  ON dr.room_id  = dt.room_id
ORDER BY dt.table_id;

-- 4d. FULL OUTER JOIN (MariaDB workaround: LEFT UNION RIGHT)
SELECT c.name AS customer_name, r.reservation_id, r.reserved_for
FROM customer c
LEFT JOIN reservation r ON r.customer_id = c.customer_id
UNION
SELECT c.name, r.reservation_id, r.reserved_for
FROM customer c
RIGHT JOIN reservation r ON c.customer_id = r.customer_id
ORDER BY customer_name;

-- 4e. CROSS JOIN — Every restaurant × customer pairing
SELECT r.name AS restaurant, c.name AS customer
FROM restaurant r
CROSS JOIN customer c
ORDER BY r.name, c.name;

-- 4f. SELF JOIN — Pairs of coworkers at the same restaurant
SELECT
    e1.name AS employee_1,
    e2.name AS employee_2,
    r.name  AS restaurant
FROM employee e1
JOIN employee e2   ON e1.restaurant_id = e2.restaurant_id
                   AND e1.employee_id < e2.employee_id
JOIN restaurant r  ON r.restaurant_id  = e1.restaurant_id
ORDER BY r.name, e1.name;

-- 4g. NATURAL JOIN — dining_room and restaurant on shared restaurant_id
SELECT *
FROM dining_room
NATURAL JOIN restaurant;

-- 4h. Multi-table JOIN (5 tables) — Full order detail
SELECT
    c.name            AS customer,
    mi.name           AS item_name,
    mi.course,
    oi.qty,
    mi.price,
    (oi.qty * mi.price) AS line_total,
    o.ordered_at
FROM customer c
JOIN visit v         ON v.customer_id  = c.customer_id
JOIN orders o        ON o.visit_id     = v.visit_id
JOIN order_item oi   ON oi.order_id    = o.order_id
JOIN menu_item mi    ON mi.item_id     = oi.item_id
ORDER BY c.name, o.ordered_at;


-- ============================================================================
-- SECTION 5: SET OPERATIONS
-- ============================================================================

-- 5a. UNION — Customers with a reservation OR a visit
SELECT customer_id, name, 'Has Reservation' AS status FROM customer
WHERE customer_id IN (SELECT customer_id FROM reservation)
UNION
SELECT customer_id, name, 'Has Visited' AS status FROM customer
WHERE customer_id IN (SELECT customer_id FROM visit WHERE customer_id IS NOT NULL);

-- 5b. UNION ALL — Same but keeps duplicates
SELECT customer_id, name, 'Has Reservation' AS status FROM customer
WHERE customer_id IN (SELECT customer_id FROM reservation)
UNION ALL
SELECT customer_id, name, 'Has Visited' AS status FROM customer
WHERE customer_id IN (SELECT customer_id FROM visit WHERE customer_id IS NOT NULL);

-- 5c. INTERSECT — Customers with BOTH reservation AND visit
SELECT customer_id, name FROM customer
WHERE customer_id IN (SELECT customer_id FROM reservation)
INTERSECT
SELECT customer_id, name FROM customer
WHERE customer_id IN (SELECT customer_id FROM visit WHERE customer_id IS NOT NULL);

-- 5d. EXCEPT — Customers with reservation but NO visit
SELECT customer_id, name FROM customer
WHERE customer_id IN (SELECT customer_id FROM reservation)
EXCEPT
SELECT customer_id, name FROM customer
WHERE customer_id IN (SELECT customer_id FROM visit WHERE customer_id IS NOT NULL);


-- ============================================================================
-- SECTION 6: SUBQUERIES
-- ============================================================================

-- 6a. Scalar subquery — Employees earning above average (excluding managers)
SELECT name, role, pay_rate
FROM employee
WHERE pay_rate > (SELECT AVG(pay_rate) FROM employee WHERE role != 'manager')
ORDER BY pay_rate DESC;

-- 6b. IN subquery — Menu items never ordered
SELECT mi.name, mi.price, mi.course
FROM menu_item mi
WHERE mi.item_id NOT IN (SELECT oi.item_id FROM order_item oi);

-- 6c. EXISTS subquery — Restaurants with at least one VIP customer visit
SELECT r.name AS restaurant
FROM restaurant r
WHERE EXISTS (
    SELECT 1
    FROM visit v
    JOIN customer c ON c.customer_id = v.customer_id
    WHERE v.restaurant_id = r.restaurant_id
      AND c.kind = 'vip'
);

-- 6d. Correlated subquery — Each server's order count
SELECT
    e.name,
    e.role,
    (SELECT COUNT(*) FROM orders o WHERE o.server_id = e.employee_id) AS orders_served
FROM employee e
WHERE e.role = 'wait_staff'
ORDER BY orders_served DESC;

-- 6e. Derived table — Busiest table by visit count
SELECT
    dt.table_no,
    dr.name AS room,
    tbl_visits.visit_count
FROM (
    SELECT table_id, COUNT(*) AS visit_count
    FROM visit
    GROUP BY table_id
) tbl_visits
JOIN dining_table dt ON dt.table_id = tbl_visits.table_id
JOIN dining_room dr  ON dr.room_id  = dt.room_id
ORDER BY tbl_visits.visit_count DESC;


-- ============================================================================
-- SECTION 7: AGGREGATES & GROUP BY / HAVING
-- ============================================================================

-- 7a. Revenue per restaurant
SELECT
    r.name AS restaurant,
    COUNT(DISTINCT b.bill_id) AS total_bills,
    SUM(b.total)              AS total_revenue,
    ROUND(AVG(b.total), 2)    AS avg_bill,
    MAX(b.total)              AS largest_bill,
    MIN(b.total)              AS smallest_bill
FROM restaurant r
JOIN visit v   ON v.restaurant_id = r.restaurant_id
JOIN bill b    ON b.visit_id      = v.visit_id
GROUP BY r.name
ORDER BY total_revenue DESC;

-- 7b. Most popular menu items (ordered 2+ times)
SELECT
    mi.name,
    mi.course,
    SUM(oi.qty) AS total_ordered
FROM menu_item mi
JOIN order_item oi ON oi.item_id = mi.item_id
GROUP BY mi.name, mi.course
HAVING SUM(oi.qty) >= 2
ORDER BY total_ordered DESC;

-- 7c. Payment method breakdown
SELECT
    method,
    COUNT(*)             AS num_payments,
    SUM(amount)          AS total_amount,
    ROUND(AVG(amount),2) AS avg_amount
FROM payment
GROUP BY method
ORDER BY total_amount DESC;

-- 7d. Employee count per role per restaurant
SELECT
    r.name AS restaurant,
    e.role,
    COUNT(*) AS headcount
FROM employee e
JOIN restaurant r ON r.restaurant_id = e.restaurant_id
GROUP BY r.name, e.role
ORDER BY r.name, e.role;


-- ============================================================================
-- SECTION 8: WINDOW FUNCTIONS
-- ============================================================================

-- 8a. Rank employees by pay within each restaurant
SELECT
    r.name  AS restaurant,
    e.name  AS employee,
    e.role,
    e.pay_rate,
    RANK()       OVER (PARTITION BY e.restaurant_id ORDER BY e.pay_rate DESC) AS pay_rank,
    DENSE_RANK() OVER (PARTITION BY e.restaurant_id ORDER BY e.pay_rate DESC) AS dense_pay_rank
FROM employee e
JOIN restaurant r ON r.restaurant_id = e.restaurant_id
ORDER BY r.name, pay_rank;

-- 8b. Running total of payments per bill
SELECT
    p.payment_id,
    p.bill_id,
    p.method,
    p.amount,
    SUM(p.amount) OVER (PARTITION BY p.bill_id ORDER BY p.paid_at) AS running_total
FROM payment p
ORDER BY p.bill_id, p.paid_at;

-- 8c. Visit number per customer
SELECT
    c.name AS customer,
    v.visit_id,
    v.started_at,
    ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY v.started_at) AS visit_number
FROM visit v
JOIN customer c ON c.customer_id = v.customer_id
ORDER BY c.name, visit_number;


-- ============================================================================
-- SECTION 9: CTEs (Common Table Expressions)
-- ============================================================================

-- 9a. Total spend per customer with tier classification
WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.name,
        c.kind,
        COALESCE(SUM(b.total), 0) AS lifetime_spend,
        COUNT(DISTINCT v.visit_id) AS visit_count
    FROM customer c
    LEFT JOIN visit v ON v.customer_id = c.customer_id
    LEFT JOIN bill b  ON b.visit_id    = v.visit_id
    GROUP BY c.customer_id, c.name, c.kind
)
SELECT
    name,
    kind,
    lifetime_spend,
    visit_count,
    CASE
        WHEN lifetime_spend > 80 THEN 'High Spender'
        WHEN lifetime_spend > 30 THEN 'Medium Spender'
        ELSE 'Low / No Spend'
    END AS spend_tier
FROM customer_spend
ORDER BY lifetime_spend DESC;

-- 9b. Visits with no bill (open or missed)
WITH unbilled_visits AS (
    SELECT v.visit_id, v.started_at, r.name AS restaurant, c.name AS customer
    FROM visit v
    JOIN restaurant r  ON r.restaurant_id = v.restaurant_id
    LEFT JOIN customer c ON c.customer_id  = v.customer_id
    LEFT JOIN bill b   ON b.visit_id       = v.visit_id
    WHERE b.bill_id IS NULL
)
SELECT * FROM unbilled_visits;


-- ============================================================================
-- SECTION 10: CASE EXPRESSIONS
-- ============================================================================

SELECT
    e.name,
    e.role,
    e.pay_rate,
    CASE e.role
        WHEN 'manager'    THEN 'Salaried'
        WHEN 'line_cook'  THEN 'Hourly - Kitchen'
        WHEN 'wait_staff' THEN 'Hourly - Front'
        WHEN 'dishwasher' THEN 'Hourly - Support'
    END AS pay_category,
    CASE
        WHEN e.pay_rate >= 50000 THEN 'Management'
        WHEN e.pay_rate >= 18    THEN 'Senior Hourly'
        ELSE 'Junior Hourly'
    END AS pay_tier
FROM employee e
ORDER BY e.pay_rate DESC;


-- ============================================================================
-- SECTION 11: UPDATE & DELETE
-- ============================================================================

-- UPDATE: Tag VIP customer emails
UPDATE customer
SET email = CONCAT(email, ' [VIP]')
WHERE kind = 'vip';

-- Undo it so emails aren't broken
UPDATE customer
SET email = REPLACE(email, ' [VIP]', '')
WHERE email LIKE '% [VIP]';

-- UPDATE: 5% raise for line cooks at restaurant 1
UPDATE employee
SET pay_rate = pay_rate * 1.05
WHERE role = 'line_cook' AND restaurant_id = 1;

-- DELETE: Remove inactive menus (must delete entire FK chain bottom-up)
DELETE FROM cook_assignment WHERE (order_id, item_id) IN (
    SELECT oi.order_id, oi.item_id FROM order_item oi
    WHERE oi.item_id IN (SELECT item_id FROM menu_item WHERE menu_id IN (SELECT menu_id FROM menu WHERE active = 0))
);
DELETE FROM order_item WHERE item_id IN (
    SELECT item_id FROM menu_item WHERE menu_id IN (SELECT menu_id FROM menu WHERE active = 0)
);
DELETE FROM menu_item WHERE menu_id IN (SELECT menu_id FROM menu WHERE active = 0);
DELETE FROM menu WHERE active = 0;


-- ============================================================================
-- SECTION 12: VIEWS
-- ============================================================================

CREATE OR REPLACE VIEW v_visit_details AS
SELECT
    v.visit_id,
    r.name          AS restaurant_name,
    c.name          AS customer_name,
    c.kind          AS customer_kind,
    dt.table_no,
    dr.name         AS room_name,
    v.started_at,
    v.ended_at,
    CASE WHEN v.reservation_id IS NOT NULL THEN 'Reservation' ELSE 'Walk-In' END AS visit_type
FROM visit v
JOIN restaurant r    ON r.restaurant_id = v.restaurant_id
LEFT JOIN customer c ON c.customer_id   = v.customer_id
JOIN dining_table dt ON dt.table_id     = v.table_id
JOIN dining_room dr  ON dr.room_id      = dt.room_id;

SELECT * FROM v_visit_details ORDER BY visit_id;


-- ============================================================================
-- SECTION 13: COMPLEX QUERIES
-- ============================================================================

-- 13a. Full receipt for visit 1
SELECT
    r.name                  AS restaurant,
    c.name                  AS customer,
    dt.table_no,
    mi.name                 AS item,
    mi.course,
    oi.qty,
    mi.price                AS unit_price,
    (oi.qty * mi.price)     AS line_total,
    b.total                 AS bill_total,
    p.method                AS pay_method,
    p.amount                AS amount_paid
FROM visit v
JOIN restaurant r    ON r.restaurant_id = v.restaurant_id
LEFT JOIN customer c ON c.customer_id   = v.customer_id
JOIN dining_table dt ON dt.table_id     = v.table_id
JOIN orders o        ON o.visit_id      = v.visit_id
JOIN order_item oi   ON oi.order_id     = o.order_id
JOIN menu_item mi    ON mi.item_id      = oi.item_id
LEFT JOIN bill b     ON b.visit_id      = v.visit_id
LEFT JOIN payment p  ON p.bill_id       = b.bill_id
WHERE v.visit_id = 1
ORDER BY o.ordered_at, mi.course;

-- 13b. Which cooks prepared what and for whom
SELECT
    cook_emp.name       AS cook,
    lc.station,
    mi.name             AS dish,
    oi.qty,
    oi.notes,
    cust.name           AS customer,
    ca.assigned_at
FROM cook_assignment ca
JOIN line_cook lc        ON lc.employee_id   = ca.cook_id
JOIN employee cook_emp   ON cook_emp.employee_id = ca.cook_id
JOIN order_item oi       ON oi.order_id = ca.order_id AND oi.item_id = ca.item_id
JOIN menu_item mi        ON mi.item_id  = oi.item_id
JOIN orders o            ON o.order_id  = ca.order_id
JOIN visit v             ON v.visit_id  = o.visit_id
LEFT JOIN customer cust  ON cust.customer_id = v.customer_id
ORDER BY ca.assigned_at;

-- 13c. Revenue by restaurant with ROLLUP
SELECT
    COALESCE(sub.rname, '*** ALL RESTAURANTS ***') AS restaurant,
    COALESCE(sub.bill_date, '** ALL DATES **')     AS bill_date,
    SUM(sub.total)      AS daily_revenue,
    COUNT(sub.bill_id)  AS bill_count
FROM (
    SELECT r.name AS rname, CAST(DATE(b.closed_at) AS CHAR) AS bill_date, b.total, b.bill_id
    FROM bill b
    JOIN visit v      ON v.visit_id       = b.visit_id
    JOIN restaurant r ON r.restaurant_id  = v.restaurant_id
) sub
GROUP BY sub.rname, sub.bill_date WITH ROLLUP;



SELECT * FROM restaurant;
