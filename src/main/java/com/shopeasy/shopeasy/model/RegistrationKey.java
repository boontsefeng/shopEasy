package com.shopeasy.shopeasy.model;

import jakarta.persistence.*;
import java.io.Serializable;
import java.sql.Timestamp;

/**
 * RegistrationKey model class representing special keys for staff/admin registration
 */
@Entity
@Table(name = "registration_keys")
public class RegistrationKey implements Serializable {
    
    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "key_id")
    private int keyId;
    
    @Column(name = "key_value", nullable = false, length = 64, unique = true)
    private String keyValue;
    
    @Column(name = "role", nullable = false, length = 20)
    private String role;
    
    @Column(name = "is_used", nullable = false)
    private boolean isUsed;
    
    @Column(name = "generated_by", nullable = false)
    private int generatedBy;
    
    @Column(name = "created_at", nullable = false)
    private Timestamp createdAt;
    
    @Column(name = "expires_at", nullable = false)
    private Timestamp expiresAt;
    
    // Default constructor
    public RegistrationKey() {
    }
    
    // Constructor with all fields
    public RegistrationKey(int keyId, String keyValue, String role, boolean isUsed, int generatedBy, Timestamp createdAt, Timestamp expiresAt) {
        this.keyId = keyId;
        this.keyValue = keyValue;
        this.role = role;
        this.isUsed = isUsed;
        this.generatedBy = generatedBy;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }
    
    // Constructor without keyId (for new keys)
    public RegistrationKey(String keyValue, String role, boolean isUsed, int generatedBy, Timestamp createdAt, Timestamp expiresAt) {
        this.keyValue = keyValue;
        this.role = role;
        this.isUsed = isUsed;
        this.generatedBy = generatedBy;
        this.createdAt = createdAt;
        this.expiresAt = expiresAt;
    }
    
    // Getters and Setters
    public int getKeyId() {
        return keyId;
    }
    
    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }
    
    public String getKeyValue() {
        return keyValue;
    }
    
    public void setKeyValue(String keyValue) {
        this.keyValue = keyValue;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isUsed() {
        return isUsed;
    }
    
    public void setUsed(boolean used) {
        isUsed = used;
    }
    
    public int getGeneratedBy() {
        return generatedBy;
    }
    
    public void setGeneratedBy(int generatedBy) {
        this.generatedBy = generatedBy;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getExpiresAt() {
        return expiresAt;
    }
    
    public void setExpiresAt(Timestamp expiresAt) {
        this.expiresAt = expiresAt;
    }
    
    @Override
    public String toString() {
        return "RegistrationKey{" +
                "keyId=" + keyId +
                ", keyValue='" + keyValue + '\'' +
                ", role='" + role + '\'' +
                ", isUsed=" + isUsed +
                ", generatedBy=" + generatedBy +
                ", createdAt=" + createdAt +
                ", expiresAt=" + expiresAt +
                '}';
    }
}