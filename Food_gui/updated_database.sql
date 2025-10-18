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
    FOREIGN KEY (collector_username) REFERENCES users(username)
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
    food_item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    item_type ENUM('ordered', 'requested') NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    PRIMARY KEY (order_id, food_item_name, item_type)
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

-- Create indexes for better performance
CREATE INDEX idx_food_items_name ON food_items(food_item_name);
CREATE INDEX idx_food_items_status ON food_items(status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_requests_date ON requests(request_date);
CREATE INDEX idx_requests_status ON requests(status);
CREATE INDEX idx_collected_date ON collected_items(collection_date);
CREATE INDEX idx_wasted_date ON wasted_items(waste_date);

-- Insert initial test users
INSERT IGNORE INTO users (username, password, role, name) VALUES
('collector1', 'pass', 'Collector', 'John Doe'),
('collector2', 'pass', 'Collector', 'Jane Smith'),
('provider1', 'pass', 'Provider', 'Food Co.'),
('provider2', 'pass', 'Provider', 'Green Grocers'),
('DB', 'DB', 'Collector', 'DB User');