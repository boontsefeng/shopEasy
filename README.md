# 🛒 ShopEasy - E-commerce Web Application

## 📋 Overview
**ShopEasy** is a comprehensive e-commerce web application built with JSP, MySQL, and Apache Tomcat 10. This Maven-based project provides a complete shopping experience with user and admin interfaces, product management, cart functionality, order processing, and more.

![ShopEasy Banner](https://placeholder.pics/svg/1200x300/FFD700-FFB900/000000/SHOPEASY%20-%20SHOP%20WITH%20EASE)

## ✅ Prerequisites
- 🔸 JDK 11 or higher
- 🔸 Apache Tomcat 10
- 🔸 MySQL Server (can be installed standalone or via XAMPP)
- 🔸 NetBeans IDE (recommended)
- 🔸 Maven (integrated with NetBeans)

## 🚀 Installation and Setup Guide

### 1️⃣ Setting up MySQL
#### Option A: Using XAMPP (Recommended) 🌟
1. Download and install XAMPP from [https://www.apachefriends.org/](https://www.apachefriends.org/)
2. Start the XAMPP Control Panel and start the MySQL service
3. Open phpMyAdmin by clicking the "Admin" button next to MySQL
4. Create a new database named `shopeasy`
5. Import the provided SQL file (`database/shopeasy.sql`) to set up the database structure

#### Option B: Using MySQL Server
1. Install MySQL Server from [https://dev.mysql.com/downloads/](https://dev.mysql.com/downloads/)
2. Create a new database named `shopeasy`
3. Import the provided SQL file (`shopeasy.sql`)

### 2️⃣ Setting up Apache Tomcat 10
1. Download Apache Tomcat 10 from [https://tomcat.apache.org/download-10.cgi](https://tomcat.apache.org/download-10.cgi)
2. Extract the downloaded file to a location on your computer (e.g., `C:\tomcat10` or `/opt/tomcat10`)

#### Configuring Tomcat Admin Panel 🛠️
1. Navigate to the `conf` directory in your Tomcat installation
2. Edit the `tomcat-users.xml` file and add the following lines before the closing `</tomcat-users>` tag:
   ```xml
   <role rolename="admin-gui"/>
   <role rolename="manager-gui"/>
   <user username="your_username" password="your_password" roles="admin-gui,manager-gui"/>
   ```
3. Save and close the file
4. Start Tomcat by running the `startup.bat` (Windows) or `startup.sh` (Linux/Mac) script from the `bin` directory
5. Access the Tomcat admin panel at [http://localhost:8080/manager/html](http://localhost:8080/manager/html)
6. Log in with the credentials you set in `tomcat-users.xml`

### 3️⃣ Setting up NetBeans with Tomcat
1. Open NetBeans IDE
2. Go to Tools > Servers
3. Click "Add Server"
4. Select "Apache Tomcat or TomEE" and click "Next"
5. Browse to the Tomcat installation directory
6. Set the username and password to match those in `tomcat-users.xml`
7. Click "Finish"

### 4️⃣ Importing the ShopEasy Project in NetBeans
1. Go to File > Open Project
2. Navigate to the ShopEasy project directory and open it
3. Right-click on the project and select "Properties"
4. In the "Run" category, ensure that Apache Tomcat is selected as the server
5. Click "OK"

### 5️⃣ Database Configuration
Verify that the database connection settings in `src/main/java/com/shopeasy/util/DBUtil.java` match your local settings:

```java
public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/shopeasy";
    private static final String USERNAME = "root";
    private static final String PASSWORD = ""; // Make sure this matches your local MySQL password
    
    // Rest of the class...
}
```

### 6️⃣ Running the Project
1. Right-click on the project in NetBeans
2. Select "Clean and Build"
3. Once built successfully, click the "Run" button or right-click and select "Run"
4. NetBeans will deploy the application to Tomcat and open it in your default web browser

## 🌈 Application Features

### 👤 User Features
- **🔐 User Authentication**: Login, registration, and password reset with OTP
- **🔍 Product Browsing**: View all products with filtering by categories
- **🛒 Shopping Cart**: Add products, modify quantities, remove items
- **💳 Checkout Process**: Enter shipping details and select payment method
- **📦 Order Tracking**: View order history and status
- **👤 Profile Management**: View and update personal information
- **🎁 Special Promotions**: View discounts and special offers (e.g., Raya Discounts)

### 👨‍💼 Admin/Staff Features
- **📋 Product Management**: Add, edit, restock, delete products, and update images
- **📊 Order Management**: View order details and update order status
- **👥 Customer Management**: View customer information and manage accounts
- **👨‍💻 Staff Management**: Add new staff accounts, manage roles and permissions
- **📝 Reporting**: Generate sales reports for specified periods
- **🔑 Registration Key Generation**: Create keys for staff or manager accounts (Manager only)

### ⚠️ Important Testing Notes
- The OTP system has a maximum of **5 tries** for testing purposes. Please use this feature sparingly to avoid lockouts during testing and evaluation.

## 🔧 Troubleshooting

### Common Issues:
1. **📡 Database Connection Error**:
   - Verify that MySQL service is running
   - Check the password in DBUtil.java matches your MySQL password
   - Ensure the database name is correct

2. **🖥️ Tomcat Connection Issues**:
   - Verify Tomcat is running (check if http://localhost:8080 is accessible)
   - Ensure the correct version (Tomcat 10) is being used
   - Check server logs for specific error messages

3. **📚 Maven Dependencies**:
   - Run `mvn clean install` from command line to ensure all dependencies are properly downloaded
   - Check for any conflicts in the pom.xml file

4. **🚀 Deployment Issues**:
   - Clear Tomcat cache by deleting contents of the `work` directory in Tomcat installation
   - Restart Tomcat and try deploying again

### 📞 Technical Support
For additional assistance, please contact us at +60 10-273 4914 or +60 11-2400 8260 

## 💻 Development Notes
- This is a **Maven-based project**. All dependencies are managed in the pom.xml file
- The application uses **JSP** for the view layer, **servlets** for controllers, and **Java beans** for models
- Database interactions are handled through **JDBC** with connection pooling for efficiency
- Front-end uses **Bootstrap** for responsive design and **jQuery** for enhanced user experience

---

© 2025 ShopEasy. All rights reserved. 🛍️