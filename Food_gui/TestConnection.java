public class TestConnection {
    public static void main(String[] args) {
        boolean isConnected = DatabaseConnection.testConnection();
        if (!isConnected) {
            System.out.println("\nPossible issues to check:");
            System.out.println("1. Verify MySQL is running on port 3306");
            System.out.println("2. Check if database 'food_application' exists");
            System.out.println("3. Verify username 'root' has access");
            System.out.println("4. Confirm password is correct");
        }
    }
}