import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class Collector extends User {
    private List<FoodItem> collectedItems; // List to store collected food items

    // Constructor that initializes the collector
    public Collector(String username, String password, String name) {
        super(username, password, "Collector", name); // Call the User constructor
        this.collectedItems = new ArrayList<>(); // Initialize the list of collected items
        loadCollectedItems(); // Load items from the database
    }

    // Method to add a collected item
    public void addCollectedItem(FoodItem item) {
        if (item != null) {
            collectedItems.add(item); // Add the item to the collected items list
            saveCollectedItemToDatabase(item); // Save the item to the database
        } else {
            System.out.println("Cannot add collected item: Item is null.");
        }
    }

    // Method to get the list of collected items
    public List<FoodItem> getCollectedItems() {
        return new ArrayList<>(collectedItems); // Return a copy to prevent modification
    }

    // Method to save collected item to the database
    private void saveCollectedItemToDatabase(FoodItem item) {
        String sql = "INSERT INTO collected_items (collector_username, food_item_name, quantity, unit) VALUES (?, ?, ?, ?)";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            // Set parameters for the SQL statement
            statement.setString(1, this.getUsername()); // Use the collector's username
            statement.setString(2, item.getName());
            statement.setDouble(3, item.getQuantity()); // Use double for quantity
            statement.setString(4, item.getUnit()); // Set the unit of the food item

            int rowsInserted = statement.executeUpdate();
            if (rowsInserted > 0) {
                System.out.println("Collected item '" + item.getName() + "' added successfully.");
            }
        } catch (SQLException e) {
            System.out.println("SQL Error: Failed to save collected item '" + item.getName() + "' - " + e.getMessage());
        }
    }

    // Method to load collected items from the database
    private void loadCollectedItems() {
        String sql = "SELECT food_item_name, quantity, unit, collection_date FROM collected_items WHERE collector_username = ?";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
             
            statement.setString(1, this.getUsername()); // Use the collector's username

            ResultSet resultSet = statement.executeQuery();
            while (resultSet.next()) {
                String name = resultSet.getString("food_item_name");
                double quantity = resultSet.getDouble("quantity");
                String unit = resultSet.getString("unit"); // Retrieve the unit
                java.sql.Date sqlDate = resultSet.getDate("collection_date");
                LocalDate collectionDate = sqlDate != null ? sqlDate.toLocalDate() : LocalDate.now();

                FoodItem item = new FoodItem(name, quantity, unit, collectionDate); // Create FoodItem instance
                collectedItems.add(item); // Add to the list
            }
        } catch (SQLException e) {
            System.out.println("SQL Error: Failed to load collected items - " + e.getMessage());
        }
    }

    // Method to load wasted items from the database
    public List<FoodItem> getWastedItems() {
        List<FoodItem> wastedItems = new ArrayList<>();
        String sql = "SELECT food_item_name, quantity, unit, waste_date FROM wasted_items";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
             
            ResultSet resultSet = statement.executeQuery();
            while (resultSet.next()) {
                String name = resultSet.getString("food_item_name");
                double quantity = resultSet.getDouble("quantity");
                String unit = resultSet.getString("unit");
                java.sql.Date sqlWasteDate = resultSet.getDate("waste_date");
                LocalDate wasteDate = sqlWasteDate != null ? sqlWasteDate.toLocalDate() : LocalDate.now();

                FoodItem item = new FoodItem(name, quantity, unit, wasteDate);
                wastedItems.add(item); // Add to the list
            }
        } catch (SQLException e) {
            System.out.println("SQL Error: Failed to load wasted items - " + e.getMessage());
        }
        return wastedItems; // Return the list of wasted items
    }
}
