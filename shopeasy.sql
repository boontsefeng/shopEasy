-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 28, 2025 at 05:02 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `shopeasy`
--

-- --------------------------------------------------------

--
-- Table structure for table `cartitems`
--

CREATE TABLE `cartitems` (
  `cart_item_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cartitems`
--

INSERT INTO `cartitems` (`cart_item_id`, `user_id`, `product_id`, `quantity`) VALUES
(3, 3, 1, 1),
(4, 3, 4, 2),
(5, 3, 8, 1),
(6, 9, 2, 1),
(7, 9, 5, 1),
(8, 9, 7, 1);

-- --------------------------------------------------------

--
-- Table structure for table `orderitems`
--

CREATE TABLE `orderitems` (
  `order_item_id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orderitems`
--

INSERT INTO `orderitems` (`order_item_id`, `order_id`, `product_id`, `quantity`, `price`) VALUES
(21, 1, 1, 1, 12999.00),
(22, 1, 3, 1, 1999.00),
(23, 8, 1, 1, 12999.00),
(24, 8, 7, 1, 2000.00),
(25, 9, 7, 1, 2499.00),
(26, 10, 1, 1, 12999.00),
(27, 10, 5, 1, 4991.00),
(28, 11, 5, 1, 4999.00),
(29, 12, 2, 1, 8999.00),
(30, 13, 5, 1, 4999.00),
(31, 14, 4, 1, 1499.00),
(32, 15, 3, 2, 1999.00),
(33, 15, 6, 1, 4000.00),
(34, 16, 3, 1, 1999.00),
(35, 16, 7, 1, 1999.00),
(36, 17, 8, 1, 2999.00),
(37, 18, 1, 1, 8999.00),
(38, 18, 8, 1, 999.00),
(39, 19, 6, 1, 3499.00),
(40, 20, 5, 1, 4999.00),
(41, 20, 3, 1, 1000.00),
(42, 21, 3, 1, 1999.00),
(43, 22, 4, 3, 1499.00),
(44, 23, 5, 1, 4999.00),
(45, 23, 3, 1, 1999.00),
(46, 24, 3, 1, 1999.00),
(47, 24, 8, 1, 999.00),
(48, 25, 1, 1, 12999.00),
(49, 25, 7, 1, 1999.00),
(50, 26, 2, 1, 8499.00),
(51, 26, 8, 1, 999.00);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `shipping_address` text NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_method` enum('cash','credit','debit','e-wallet') NOT NULL,
  `order_status` enum('packaging','shipping','delivery','delivered') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `user_id`, `order_date`, `shipping_address`, `total_amount`, `payment_method`, `order_status`) VALUES
(1, 9, '2025-04-21 22:52:33', 'taman melati', 14998.00, 'cash', 'packaging'),
(8, 3, '2025-04-07 07:16:14', '123 Pine Street, San Francisco, CA 94101', 14999.00, 'credit', 'delivered'),
(9, 3, '2025-04-14 07:16:14', '123 Pine Street, San Francisco, CA 94101', 2499.00, 'e-wallet', 'delivered'),
(10, 9, '2025-04-08 07:16:14', '456 Oak Avenue, San Jose, CA 95113', 17990.00, 'credit', 'delivered'),
(11, 9, '2025-04-19 07:16:14', '456 Oak Avenue, San Jose, CA 95113', 4999.00, 'debit', 'shipping'),
(12, 3, '2025-04-04 07:21:59', '789 Pine Avenue, Portland, OR 97209', 8999.00, 'credit', 'delivered'),
(13, 3, '2025-04-06 07:21:59', '789 Pine Avenue, Portland, OR 97209', 4999.00, 'cash', 'delivered'),
(14, 3, '2025-04-12 07:21:59', '789 Pine Avenue, Portland, OR 97209', 1499.00, 'e-wallet', 'delivered'),
(15, 3, '2025-04-19 07:21:59', '789 Pine Avenue, Portland, OR 97209', 7998.00, 'credit', 'delivery'),
(16, 3, '2025-04-22 07:21:59', '789 Pine Avenue, Portland, OR 97209', 3998.00, 'debit', 'shipping'),
(17, 3, '2025-04-23 07:21:59', '789 Pine Avenue, Portland, OR 97209', 2999.00, 'e-wallet', 'packaging'),
(18, 9, '2025-04-09 07:21:59', 'taman melati', 9998.00, 'cash', 'delivered'),
(19, 9, '2025-04-11 07:21:59', 'taman melati', 3499.00, 'credit', 'delivered'),
(20, 9, '2025-04-13 07:21:59', 'taman melati', 5999.00, 'e-wallet', 'delivered'),
(21, 9, '2025-04-17 07:21:59', 'taman melati', 1999.00, 'cash', 'delivered'),
(22, 9, '2025-04-18 07:21:59', 'taman melati', 4499.00, 'credit', 'delivered'),
(23, 9, '2025-04-20 07:21:59', 'taman melati', 6998.00, 'e-wallet', 'delivery'),
(24, 9, '2025-04-21 07:21:59', 'taman melati', 2998.00, 'cash', 'shipping'),
(25, 9, '2025-04-22 07:21:59', 'taman melati', 14998.00, 'debit', 'shipping'),
(26, 9, '2025-04-23 23:21:59', 'taman melati', 9498.00, 'credit', 'packaging');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text NOT NULL,
  `category` varchar(50) NOT NULL,
  `price` int(11) NOT NULL,
  `quantity` int(11) NOT NULL,
  `image_path` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `description`, `category`, `price`, `quantity`, `image_path`) VALUES
(1, 'Wireless Bluetooth Headphones', 'High-quality wireless headphones with noise cancellation.', 'Electronics', 12999, 23, 'assets/wireless-bluetooth-headphones.jpg'),
(2, 'Smart Watch with Fitness Tracker', 'Track your fitness and receive notifications on the go.', 'Electronics', 8999, 0, 'assets/Smart Watch with Fitness Tracker.jpg'),
(3, 'Men\'s Cotton T-Shirt', 'Comfortable 100% cotton t-shirt for everyday wear.', 'Clothing', 1999, 49, 'assets/Men\'s Cotton T-Shirt.png'),
(4, 'Ceramic Coffee Mug', 'Elegant ceramic coffee mug for your morning brew.', 'Home & Garden', 1499, 35, 'assets/Ceramic Coffee Mug.jpg'),
(5, 'Portable Bluetooth Speaker', 'Compact speaker with impressive sound quality.', 'Electronics', 4999, 18, 'assets/Portable Bluetooth Speaker.jpg'),
(6, 'LED Desk Lamp', 'Adjustable desk lamp with multiple brightness levels.', 'Home & Garden', 3499, 12, 'assets/LED Desk Lamp.png'),
(7, 'Stainless Steel Water Bottle', 'Keep your drinks hot or cold for hours.', 'Home & Garden', 2499, 30, 'assets/Stainless Steel Water Bottle.jpg'),
(8, 'Yoga Mat', 'Non-slip yoga mat for all your fitness needs.', 'Sports', 2999, 20, 'assets/Yoga Mat.jpg'),
(9, 'Small Phallic Object', '', 'Electronics', 738800, 50, 'assets/FrostGuard Refrigerator.png');

-- --------------------------------------------------------

--
-- Table structure for table `ratings`
--

CREATE TABLE `ratings` (
  `rating_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `rating` int(11) NOT NULL,
  `comment` text NOT NULL,
  `rating_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ratings`
--

INSERT INTO `ratings` (`rating_id`, `product_id`, `user_id`, `rating`, `comment`, `rating_date`) VALUES
(1, 1, 3, 5, 'Excellent sound quality and very comfortable to wear for long periods. Battery life is amazing!', '2025-04-09 07:17:06'),
(2, 1, 9, 4, 'Great headphones with impressive noise cancellation. The only downside is they\'re a bit heavy after a few hours.', '2025-04-11 07:17:06'),
(3, 2, 3, 4, 'Tracks my workouts accurately and the battery lasts about 5 days. Very happy with this purchase.', '2025-04-10 07:17:06'),
(4, 2, 9, 3, 'Good fitness tracking but the sleep tracking isn\'t very accurate. The app could use some improvements.', '2025-04-17 07:17:06'),
(5, 3, 3, 5, 'Very comfortable fabric and fits perfectly. Will definitely buy more colors.', '2025-04-15 07:17:06'),
(6, 3, 9, 4, 'Good quality shirt that has held up well after multiple washes. The fit is slightly larger than expected.', '2025-04-13 07:17:06'),
(7, 4, 3, 5, 'Beautiful mug that keeps my coffee hot for a long time. The handle is comfortable to hold.', '2025-04-12 07:17:06'),
(8, 4, 9, 4, 'Nice design and good quality. I wish it came in more colors.', '2025-04-14 07:17:06'),
(9, 1, 3, 5, 'Amazing sound quality and the battery lasts forever! The noise cancellation is top-notch.', '2025-04-08 07:22:38'),
(10, 1, 9, 4, 'Great headphones with impressive bass. Comfortable to wear for long periods.', '2025-04-12 07:22:38'),
(11, 2, 3, 4, 'Very accurate fitness tracking and the battery lasts for days. App could be better though.', '2025-04-05 07:22:38'),
(12, 2, 9, 5, 'This smartwatch has changed my fitness routine completely. Love all the features!', '2025-04-10 07:22:38'),
(13, 3, 3, 5, 'Best cotton t-shirt I\'ve ever owned. Feels premium and fits perfectly.', '2025-04-13 07:22:38'),
(14, 3, 9, 5, 'Super comfortable and looks great. Washes well without shrinking.', '2025-04-18 07:22:38'),
(15, 4, 3, 4, 'Good quality mug that keeps coffee hot for a long time. Design is exactly as pictured.', '2025-04-14 07:22:38'),
(16, 4, 9, 5, 'Perfect size and very stylish. Makes my morning coffee more enjoyable!', '2025-04-19 07:22:38'),
(17, 5, 3, 5, 'Incredible sound for such a compact speaker. Battery lasts all day at the beach!', '2025-04-07 07:22:38'),
(18, 5, 9, 4, 'Great speaker with powerful sound. The Bluetooth connection is very stable.', '2025-04-15 07:22:38'),
(19, 6, 3, 4, 'Adjustable brightness is perfect for late night work. Sleek design too.', '2025-04-16 07:22:38'),
(20, 6, 9, 5, 'This lamp completely transformed my workspace. Multiple light modes are great for different tasks.', '2025-04-21 07:22:38'),
(21, 7, 3, 5, 'Keeps water cold for 24 hours even in hot weather! No leaks at all.', '2025-04-11 07:22:38'),
(22, 7, 9, 4, 'Great bottle that fits perfectly in my car cup holder. Easy to clean too.', '2025-04-20 07:22:38'),
(23, 8, 3, 5, 'Perfect thickness and grip for all types of yoga. Easy to clean after workouts.', '2025-04-17 07:22:38'),
(24, 8, 9, 4, 'Good quality mat that doesn\'t slip on hardwood floors. Wish it came with a carry strap.', '2025-04-22 07:22:38');

-- --------------------------------------------------------

--
-- Table structure for table `registration_keys`
--

CREATE TABLE `registration_keys` (
  `key_id` int(11) NOT NULL,
  `key_value` varchar(64) NOT NULL,
  `role` enum('manager','staff') NOT NULL,
  `is_used` tinyint(1) NOT NULL DEFAULT 0,
  `generated_by` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT '2030-12-31 15:59:59'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('manager','staff','customer') NOT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 1,
  `name` varchar(100) NOT NULL,
  `contact_number` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `username`, `password`, `role`, `is_approved`, `name`, `contact_number`, `email`, `registration_date`) VALUES
(3, 'customer', 'customer123', 'customer', 1, 'Mike Customer', '+1-234-567-8903', 'customer@example.com', '2025-04-18 03:49:32'),
(5, 'boontsefeng', 'hHRPiNpFmdfccnmA+9ZQaw==:k+SXQSwEXGBi7uRB0me6Aha0AcJFjcXiO2hDHeIl3jY=', 'manager', 1, 'Maxwell Boon Tse Feng', '01124008260', 'maxwellbtf@gmail.com', '2025-04-18 12:41:49'),
(6, 'shah', 'L98wPQtqYFAA6sFx0gLLog==:9Fq52GKqhqEH8CQwPyOlBk1dpkiinT7RCWjNN+T48VA=', 'manager', 1, 'Mukhtar Shah', '0102734914', 'mukhtar61@gmail.com', '2025-04-19 05:10:05'),
(7, 'balls', 'LaQVw11sZsUKenGzM/ZEyA==:LDXkNQCkgmvk5uZxvAwlkj7BysF1DypXIHZ/AslCyNA=', 'staff', 1, 'ambalbubu', '01124007360', 'ambalabu@gmail.com', '2025-04-19 05:13:36'),
(8, 'brrbrrpatapim', '8UgHM4nEEDmyb52W4PiHPw==:EIuiAjDI7fweX9UOE0pP0cI6btpf2aLAF958r+F52Co=', 'manager', 1, 'TUNGTUNGTUNGSAHUR', '01124007360', 'akunakmati@gmail.com', '2025-04-19 05:18:52'),
(9, 'boon', 'jjZ72LZB0vPwslE2FC5MaQ==:o7uax01Wwuve64LlAFzGJcZ6ZyBI4TPGBksbV5aP31M=', 'customer', 1, 'boon', '01124008260', 'matilababi@gmail.com', '2025-04-22 03:08:57'),
(10, 'alex_smith', 'customer123', 'customer', 1, 'Alex Smith', '+1-650-555-1122', 'asmith@example.com', '2025-04-24 07:16:01'),
(11, 'priya_patel', 'customer123', 'customer', 1, 'Priya Patel', '+1-408-555-3344', 'ppatel@example.com', '2025-04-24 07:16:01'),
(12, 'marcus_jones', 'customer123', 'customer', 1, 'Marcus Jones', '+1-415-555-5566', 'mjones@example.com', '2025-04-24 07:16:01');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cartitems`
--
ALTER TABLE `cartitems`
  ADD PRIMARY KEY (`cart_item_id`),
  ADD KEY `cart_user_dk` (`user_id`),
  ADD KEY `cart_prod_id` (`product_id`);

--
-- Indexes for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD PRIMARY KEY (`order_item_id`),
  ADD KEY `orderitem_order_fk` (`order_id`),
  ADD KEY `orderitem_prod_fk` (`product_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`),
  ADD KEY `order_user_fk` (`user_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `ratings`
--
ALTER TABLE `ratings`
  ADD PRIMARY KEY (`rating_id`),
  ADD KEY `rating_prod_fk` (`product_id`),
  ADD KEY `rating_user_fk` (`user_id`);

--
-- Indexes for table `registration_keys`
--
ALTER TABLE `registration_keys`
  ADD PRIMARY KEY (`key_id`),
  ADD UNIQUE KEY `unique_key_value` (`key_value`),
  ADD KEY `key_generated_by_fk` (`generated_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cartitems`
--
ALTER TABLE `cartitems`
  MODIFY `cart_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `orderitems`
--
ALTER TABLE `orderitems`
  MODIFY `order_item_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `ratings`
--
ALTER TABLE `ratings`
  MODIFY `rating_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `registration_keys`
--
ALTER TABLE `registration_keys`
  MODIFY `key_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cartitems`
--
ALTER TABLE `cartitems`
  ADD CONSTRAINT `cart_prod_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `cart_user_dk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `orderitems`
--
ALTER TABLE `orderitems`
  ADD CONSTRAINT `orderitem_order_fk` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  ADD CONSTRAINT `orderitem_prod_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `order_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `ratings`
--
ALTER TABLE `ratings`
  ADD CONSTRAINT `rating_prod_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `rating_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `registration_keys`
--
ALTER TABLE `registration_keys`
  ADD CONSTRAINT `key_generated_by_fk` FOREIGN KEY (`generated_by`) REFERENCES `users` (`user_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
