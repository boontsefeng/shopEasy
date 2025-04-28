import com.shopeasy.shopeasy.dao.UserDAO;
import com.shopeasy.shopeasy.model.User;

/**
 * Example code to create a user with UserDAO
 * This properly handles password hashing
 */
public class CreateUserExample {
    
    public static void main(String[] args) {
        // Create a new UserDAO instance
        UserDAO userDAO = new UserDAO();
        
        // Create a user with plain text password - the DAO will hash it automatically
        User user = new User();
        user.setUsername("shah");
        user.setPassword("shah"); // This will be automatically hashed by UserDAO.createUser()
        user.setRole("customer");
        user.setName("Shah");
        user.setContactNumber("1234567890");
        user.setEmail("shah@example.com");
        
        // Insert the user
        int userId = userDAO.createUser(user);
        
        if (userId > 0) {
            System.out.println("User created successfully with ID: " + userId);
        } else {
            System.out.println("Failed to create user. The username or email might already exist.");
        }
    }
} 