package com.shopeasy.shopeasy.model;

import jakarta.persistence.*;
import java.io.Serializable;

/**
 * User model class representing users table in database
 */
@Entity
@Table(name = "users")
public class User implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private int userId;
    
    @Column(name = "username", nullable = false, length = 50, unique = true)
    private String username;
    
    @Column(name = "password", nullable = false, length = 255)
    private String password;
    
    @Column(name = "role", nullable = false, length = 20)
    private String role;
    
    @Column(name = "name", nullable = false, length = 100)
    private String name;
    
    @Column(name = "contact_number", nullable = false, length = 20)
    private String contactNumber;
    
    @Column(name = "email", nullable = false, length = 100)
    private String email;
    
    // Default constructor
    public User() {
    }
    
    // Constructor with all fields
    public User(int userId, String username, String password, String role, String name, String contactNumber, String email) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.role = role;
        this.name = name;
        this.contactNumber = contactNumber;
        this.email = email;
    }
    
    // Constructor without userId (for new users)
    public User(String username, String password, String role, String name, String contactNumber, String email) {
        this.username = username;
        this.password = password;
        this.role = role;
        this.name = name;
        this.contactNumber = contactNumber;
        this.email = email;
    }
    
    // Getters and Setters
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getContactNumber() {
        return contactNumber;
    }
    
    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", username='" + username + '\'' +
                ", role='" + role + '\'' +
                ", name='" + name + '\'' +
                ", contactNumber='" + contactNumber + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}