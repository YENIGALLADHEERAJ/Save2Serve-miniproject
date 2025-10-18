-- Create collected_items table
CREATE TABLE IF NOT EXISTS collected_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    collector_username VARCHAR(50),
    food_item_id INT,
    collection_date DATETIME,
    FOREIGN KEY (collector_username) REFERENCES users(username),
    FOREIGN KEY (food_item_id) REFERENCES food_items(item_id)
);

-- Create wasted_items table if needed
CREATE TABLE IF NOT EXISTS wasted_items (
    waste_id INT AUTO_INCREMENT PRIMARY KEY,
    food_item_id INT,
    waste_date DATETIME,
    FOREIGN KEY (food_item_id) REFERENCES food_items(item_id)
);

-- Create requests table if needed
CREATE TABLE IF NOT EXISTS requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    collector_username VARCHAR(50),
    food_item_id INT,
    request_date DATETIME,
    status VARCHAR(20),
    FOREIGN KEY (collector_username) REFERENCES users(username),
    FOREIGN KEY (food_item_id) REFERENCES food_items(item_id)
);