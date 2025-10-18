USE food_application;

-- Drop existing tables if they exist (in correct order to handle foreign keys)
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS requests;
DROP TABLE IF EXISTS collected_items;
DROP TABLE IF EXISTS wasted_items;
DROP TABLE IF EXISTS food_items;
DROP TABLE IF EXISTS users;

-- Create users table (base table for both Providers and Collectors)
CREATE TABLE users (
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    name VARCHAR(100) NOT NULL,
    CONSTRAINT check_role CHECK (role IN ('Collector', 'Provider'))
);

-- Create food_items table
CREATE TABLE food_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_username VARCHAR(50),
    name VARCHAR(100) NOT NULL,
    food_item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    expiry_date DATE,
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Available',
    FOREIGN KEY (provider_username) REFERENCES users(username)
);

-- Create collected_items table
CREATE TABLE collected_items (
    collection_id INT AUTO_INCREMENT PRIMARY KEY,
    collector_username VARCHAR(50) NOT NULL,
    food_item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    collection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    item_id INT,
    FOREIGN KEY (collector_username) REFERENCES users(username),
    FOREIGN KEY (item_id) REFERENCES food_items(item_id)
);

-- Create wasted_items table
CREATE TABLE wasted_items (
    waste_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_username VARCHAR(50) NOT NULL,
    food_item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    waste_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (provider_username) REFERENCES users(username)
);

-- Create orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_username VARCHAR(50) NOT NULL,
    collector_username VARCHAR(50) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    notes TEXT,
    FOREIGN KEY (provider_username) REFERENCES users(username),
    FOREIGN KEY (collector_username) REFERENCES users(username)
);

-- Create order_items table
CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    item_type ENUM('ordered', 'requested') NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES food_items(item_id),
    PRIMARY KEY (order_id, item_id, item_type)
);

-- Create requests table
CREATE TABLE requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    collector_username VARCHAR(50) NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    notes TEXT,
    FOREIGN KEY (collector_username) REFERENCES users(username)
);

-- Insert initial test users
INSERT INTO users (username, password, role, name) VALUES
('collector1', 'pass', 'Collector', 'John Doe'),
('collector2', 'pass', 'Collector', 'Jane Smith'),
('provider1', 'pass', 'Provider', 'Food Co.'),
('provider2', 'pass', 'Provider', 'Green Grocers'),
('DB', 'DB', 'Collector', 'DB User');

-- Create food_items table
CREATE TABLE food_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    food_item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    expiry_date DATE,
    description TEXT,
    provider_username VARCHAR(50),
    date_added TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Available',
    FOREIGN KEY (provider_username) REFERENCES users(username)
);

-- Create orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    provider_username VARCHAR(50) NOT NULL,
    collector_username VARCHAR(50) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    notes TEXT,
    FOREIGN KEY (provider_username) REFERENCES users(username),
    FOREIGN KEY (collector_username) REFERENCES users(username)
);

-- Create order_items table (for both ordered and requested items)
CREATE TABLE order_items (
    order_id INT,
    item_id INT,
    quantity DECIMAL(10,2) NOT NULL,
    item_type ENUM('ordered', 'requested') NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES food_items(item_id),
    PRIMARY KEY (order_id, item_id, item_type)
);

-- Create requests table
CREATE TABLE requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    collector_username VARCHAR(50) NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    notes TEXT,
    FOREIGN KEY (collector_username) REFERENCES users(username)
);

-- Create collected_items table
CREATE TABLE collected_items (
    collection_id INT AUTO_INCREMENT PRIMARY KEY,
    collector_username VARCHAR(50) NOT NULL,
    item_id INT NOT NULL,
    collection_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity_collected DECIMAL(10,2) NOT NULL,
    notes TEXT,
    FOREIGN KEY (collector_username) REFERENCES users(username),
    FOREIGN KEY (item_id) REFERENCES food_items(item_id)
);

-- Create wasted_items table
CREATE TABLE wasted_items (
    waste_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    quantity_wasted DECIMAL(10,2) NOT NULL,
    waste_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (item_id) REFERENCES food_items(item_id)
);

-- Create indexes for better performance
CREATE INDEX idx_food_items_name ON food_items(name);
CREATE INDEX idx_food_items_status ON food_items(status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_requests_date ON requests(request_date);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_collected_date ON collected_items(collection_date);
CREATE INDEX idx_wasted_date ON wasted_items(waste_date);

-- Insert some initial test users
INSERT IGNORE INTO users (username, password, role, name) VALUES
('collector1', 'password123', 'Collector', 'Collector One'),
('collector2', 'password123', 'Collector', 'Collector Two'),
('provider1', 'password123', 'Provider', 'Provider One'),
('provider2', 'password123', 'Provider', 'Provider Two');

-- Create views for common queries
CREATE OR REPLACE VIEW available_food_items AS
SELECT f.*, u.name as provider_name
FROM food_items f
JOIN users u ON f.provider_username = u.username
WHERE f.status = 'Available';

CREATE OR REPLACE VIEW collection_summary AS
SELECT 
    c.collector_username,
    f.name as food_item_name,
    SUM(c.quantity_collected) as total_collected,
    COUNT(*) as collection_count,
    MAX(c.collection_date) as last_collection_date
FROM collected_items c
JOIN food_items f ON c.item_id = f.item_id
GROUP BY c.collector_username, f.name;

CREATE OR REPLACE VIEW waste_summary AS
SELECT 
    f.name as food_item_name,
    SUM(w.quantity_wasted) as total_wasted,
    COUNT(*) as waste_count,
    MAX(w.waste_date) as last_waste_date
FROM wasted_items w
JOIN food_items f ON w.item_id = f.item_id
GROUP BY f.name;