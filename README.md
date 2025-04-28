ShopEasy - E-commerce Web Application
Overview
ShopEasy is a comprehensive e-commerce web application built with JSP, MySQL, and Apache Tomcat 10. This Maven-based project provides a complete shopping experience with user and admin interfaces, product management, cart functionality, order processing, and more.
Prerequisites

JDK 11 or higher
Apache Tomcat 10
MySQL Server (can be installed standalone or via XAMPP)
NetBeans IDE (recommended)
Maven (integrated with NetBeans)

Installation and Setup Guide
1. Setting up MySQL
Option A: Using XAMPP (Recommended)

Download and install XAMPP from https://www.apachefriends.org/
Start the XAMPP Control Panel and start the MySQL service
Open phpMyAdmin by clicking the "Admin" button next to MySQL
Create a new database named shopeasy
Import the provided SQL file (database/shopeasy.sql) to set up the database structure

Option B: Using MySQL Server

Install MySQL Server from https://dev.mysql.com/downloads/
Create a new database named shopeasy
Import the provided SQL file (database/shopeasy.sql)

2. Setting up Apache Tomcat 10

Download Apache Tomcat 10 from https://tomcat.apache.org/download-10.cgi
Extract the downloaded file to a location on your computer (e.g., C:\tomcat10 or /opt/tomcat10)

Configuring Tomcat Admin Panel

Navigate to the conf directory in your Tomcat installation
Edit the tomcat-users.xml file and add the following lines before the closing </tomcat-users> tag:
xml<role rolename="admin-gui"/>
<role rolename="manager-gui"/>
<user username="admin" password="password" roles="admin-gui,manager-gui"/>

Save and close the file
Start Tomcat by running the startup.bat (Windows) or startup.sh (Linux/Mac) script from the bin directory
Access the Tomcat admin panel at http://localhost:8080/manager/html
Log in with the credentials you set in tomcat-users.xml

3. Setting up NetBeans with Tomcat

Open NetBeans IDE
Go to Tools > Servers
Click "Add Server"
Select "Apache Tomcat or TomEE" and click "Next"
Browse to the Tomcat installation directory
Set the username and password to match those in tomcat-users.xml
Click "Finish"

4. Importing the ShopEasy Project in NetBeans

Go to File > Open Project
Navigate to the ShopEasy project directory and open it
Right-click on the project and select "Properties"
In the "Run" category, ensure that Apache Tomcat is selected as the server
Click "OK"

5. Database Configuration
Verify that the database connection settings in src/main/java/com/shopeasy/util/DBUtil.java match your local settings:
javapublic class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/shopeasy";
    private static final String USERNAME = "root";
    private static final String PASSWORD = ""; // Make sure this matches your local MySQL password
    
    // Rest of the class...
}
6. Running the Project

Right-click on the project in NetBeans
Select "Clean and Build"
Once built successfully, click the "Run" button or right-click and select "Run"
NetBeans will deploy the application to Tomcat and open it in your default web browser

Application Features
User Features

User Authentication: Login, registration, and password reset with OTP
Product Browsing: View all products with filtering by categories
Shopping Cart: Add products, modify quantities, remove items
Checkout Process: Enter shipping details and select payment method
Order Tracking: View order history and status
Profile Management: View and update personal information
Special Promotions: View discounts and special offers (e.g., Raya Discounts)

Admin/Staff Features

Product Management: Add, edit, restock, delete products, and update images
Order Management: View order details and update order status
Customer Management: View customer information and manage accounts
Staff Management: Add new staff accounts, manage roles and permissions
Reporting: Generate sales reports for specified periods
Registration Key Generation: Create keys for staff or manager accounts (Manager only)

Important Testing Notes

The OTP system has a maximum of 5 tries for testing purposes. Please use this feature sparingly to avoid lockouts during testing and evaluation.

Troubleshooting
Common Issues:

Database Connection Error:

Verify that MySQL service is running
Check the password in DBUtil.java matches your MySQL password
Ensure the database name is correct


Tomcat Connection Issues:

Verify Tomcat is running (check if http://localhost:8080 is accessible)
Ensure the correct version (Tomcat 10) is being used
Check server logs for specific error messages


Maven Dependencies:

Run mvn clean install from command line to ensure all dependencies are properly downloaded
Check for any conflicts in the pom.xml file


Deployment Issues:

Clear Tomcat cache by deleting contents of the work directory in Tomcat installation
Restart Tomcat and try deploying again



Technical Support
For additional assistance, please contact the development team at support@shopeasy.com
Development Notes

This is a Maven-based project. All dependencies are managed in the pom.xml file
The application uses JSP for the view layer, servlets for controllers, and Java beans for models
Database interactions are handled through JDBC with connection pooling for efficiency
Front-end uses Bootstrap for responsive design and jQuery for enhanced user experience


© 2025 ShopEasy. All rights reserved.
