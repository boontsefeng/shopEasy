package com.shopeasy.shopeasy.model;

import java.io.Serializable;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Transient;

/**
 * Product model class representing products table in database
 */
@Entity
@Table(name = "products")
public class Product implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_id")
    private int productId;
    
    @Column(name = "name", nullable = false, length = 100)
    private String name;
    
    @Column(name = "description", nullable = false, columnDefinition = "TEXT")
    private String description;
    
    @Column(name = "category", nullable = false, length = 50)
    private String category;
    
    @Column(name = "price", nullable = false)
    private int price;
    
    @Column(name = "quantity", nullable = false)
    private int quantity;
    
    @Column(name = "image_path", nullable = false, length = 255)
    private String imagePath;
    
    // Transient fields for display purposes (not stored in database)
    @Transient
    private int originalPrice;
    
    @Transient
    private boolean discounted;
    
    // Default constructor
    public Product() {
    }
    
    // Constructor with all fields
    public Product(int productId, String name, String description, String category, int price, int quantity, String imagePath) {
        this.productId = productId;
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.quantity = quantity;
        this.imagePath = imagePath;
    }
    
    // Constructor without productId (for new products)
    public Product(String name, String description, String category, int price, int quantity, String imagePath) {
        this.name = name;
        this.description = description;
        this.category = category;
        this.price = price;
        this.quantity = quantity;
        this.imagePath = imagePath;
    }
    
    // Getters and Setters
    public int getProductId() {
        return productId;
    }
    
    public void setProductId(int productId) {
        this.productId = productId;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public int getPrice() {
        return price;
    }
    
    public void setPrice(int price) {
        this.price = price;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
    
    public int getOriginalPrice() {
        return originalPrice;
    }
    
    public void setOriginalPrice(int originalPrice) {
        this.originalPrice = originalPrice;
    }
    
    public boolean isDiscounted() {
        return discounted;
    }
    
    public void setDiscounted(boolean discounted) {
        this.discounted = discounted;
    }
    
    @Override
    public String toString() {
        return "Product{" +
                "productId=" + productId +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", category='" + category + '\'' +
                ", price=" + price +
                ", quantity=" + quantity +
                ", imagePath='" + imagePath + '\'' +
                '}';
    }
}