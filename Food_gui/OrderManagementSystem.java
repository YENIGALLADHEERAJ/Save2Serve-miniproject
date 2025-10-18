import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class OrderManagementSystem {
    // SQL queries
    private static final String INSERT_ORDER = 
        "INSERT INTO orders (provider_username, collector_username, status, notes) VALUES (?, ?, ?, ?)";
    private static final String INSERT_ORDER_ITEM = 
        "INSERT INTO order_items (order_id, food_item_name, quantity, unit, item_type) VALUES (?, ?, ?, ?, ?)";
    private static final String SELECT_COLLECTOR_ORDERS = 
        "SELECT o.order_id, o.provider_username, o.collector_username, o.order_date, o.status, o.notes, " +
        "oi.food_item_name, oi.quantity, oi.unit, oi.item_type FROM orders o " +
        "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
        "WHERE o.collector_username = ?";
    private static final String SELECT_PROVIDER_ORDERS = 
        "SELECT o.order_id, o.provider_username, o.collector_username, o.order_date, o.status, o.notes, " +
        "oi.food_item_name, oi.quantity, oi.unit, oi.item_type FROM orders o " +
        "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
        "WHERE o.provider_username = ? AND o.status = 'Pending'";
        
    // Method to get orders for a specific collector
    public List<Order> getOrdersForCollector(Collector collector) {
        Map<Integer, Order> orders = new HashMap<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_COLLECTOR_ORDERS)) {
            
            stmt.setString(1, collector.getUsername());
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                Order order = orders.get(orderId);
                if (order == null) {
                    String providerUsername = rs.getString("provider_username");
                    java.sql.Timestamp orderDate = rs.getTimestamp("order_date");
                    String status = rs.getString("status");
                    String notes = rs.getString("notes");
                    
                    // Create new order
                    order = new Order(orderId, null, collector, orderDate, new ArrayList<>(), new ArrayList<>());
                    order.setStatus(status);
                    order.setNotes(notes);
                    orders.put(orderId, order);
                }
                
                // Add order items if present
                String foodItemName = rs.getString("food_item_name");
                if (foodItemName != null) {
                    double quantity = rs.getDouble("quantity");
                    String unit = rs.getString("unit");
                    String itemType = rs.getString("item_type");
                    FoodItem item = new FoodItem(foodItemName, quantity, unit, null);
                    
                    if ("ordered".equals(itemType)) {
                        order.getOrderedItems().add(item);
                    } else if ("requested".equals(itemType)) {
                        order.getRequestedItems().add(item);
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error retrieving orders: " + e.getMessage());
            e.printStackTrace();
        }
        return new ArrayList<>(orders.values());
    }

    // Method to get pending orders for a specific provider
    public List<Order> getPendingOrdersForProvider(Provider provider) {
        Map<Integer, Order> orders = new HashMap<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(SELECT_PROVIDER_ORDERS)) {
            
            stmt.setString(1, provider.getUsername());
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                Order order = orders.get(orderId);
                if (order == null) {
                    String collectorUsername = rs.getString("collector_username");
                    java.sql.Timestamp orderDate = rs.getTimestamp("order_date");
                    String status = rs.getString("status");
                    String notes = rs.getString("notes");
                    
                    // Create new order
                    order = new Order(orderId, provider, null, orderDate, new ArrayList<>(), new ArrayList<>());
                    order.setStatus(status);
                    order.setNotes(notes);
                    orders.put(orderId, order);
                }
                
                // Add order items if present
                String foodItemName = rs.getString("food_item_name");
                if (foodItemName != null) {
                    double quantity = rs.getDouble("quantity");
                    String unit = rs.getString("unit");
                    String itemType = rs.getString("item_type");
                    FoodItem item = new FoodItem(foodItemName, quantity, unit, null);
                    
                    if ("ordered".equals(itemType)) {
                        order.getOrderedItems().add(item);
                    } else if ("requested".equals(itemType)) {
                        order.getRequestedItems().add(item);
                    }
                }
            }
        } catch (SQLException e) {
            System.out.println("Error retrieving orders: " + e.getMessage());
            e.printStackTrace();
        }
        return new ArrayList<>(orders.values());
    }

    // Method to add a new order
    public void addOrder(Order order) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            try (PreparedStatement orderStmt = conn.prepareStatement(INSERT_ORDER, Statement.RETURN_GENERATED_KEYS)) {
                // Insert order
                orderStmt.setString(1, order.getProvider().getUsername());
                orderStmt.setString(2, order.getCollector().getUsername());
                orderStmt.setString(3, order.getStatus());
                orderStmt.setString(4, order.getNotes()); // notes
                
                orderStmt.executeUpdate();
                
                // Get generated order ID
                ResultSet generatedKeys = orderStmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    int orderId = generatedKeys.getInt(1);
                    
                    // Insert ordered items
                    for (FoodItem item : order.getOrderedItems()) {
                        insertOrderItem(conn, orderId, item, "ordered");
                    }
                    
                    // Insert requested items
                    for (FoodItem item : order.getRequestedItems()) {
                        insertOrderItem(conn, orderId, item, "requested");
                    }
                    
                    conn.commit();
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            System.out.println("Error adding order: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private void insertOrderItem(Connection conn, int orderId, FoodItem item, String itemType) throws SQLException {
        try (PreparedStatement itemStmt = conn.prepareStatement(INSERT_ORDER_ITEM)) {
            itemStmt.setInt(1, orderId);
            itemStmt.setString(2, item.getName());
            itemStmt.setDouble(3, item.getQuantity());
            itemStmt.setString(4, item.getUnit());
            itemStmt.setString(5, itemType);
            itemStmt.executeUpdate();
        }
    }
    
    // Method to add a request to an existing order
    public void addRequest(Order order, FoodItem item) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            insertOrderItem(conn, order.getOrderId(), item, "requested");
        } catch (SQLException e) {
            System.out.println("Error adding request: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // Method to send a request for food items
    public void sendRequest(Collector collector, FoodItem item) {
        // Create a new order for this request
        Order order = new Order(0, null, collector, new Date(), new ArrayList<>(), new ArrayList<>());
        order.setStatus("Pending");
        order.getRequestedItems().add(item);
        addOrder(order);
        System.out.println("Request for " + item.getName() + " sent successfully.");
    }
    
    // Method to get pending requests for a specific provider
    public List<Order> getPendingRequestsForProvider(Provider provider) {
        // This is the same as getPendingOrdersForProvider since we're using the same status
        return getPendingOrdersForProvider(provider);
    }

    // Additional methods can be added as needed for managing orders and requests
}
