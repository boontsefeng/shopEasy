-- Drop the existing cartitems table (backup your data if needed)
DROP TABLE IF EXISTS cartitems;

-- Recreate the cartitems table with the correct structure
CREATE TABLE cartitems (
  cart_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Create an index for better performance
CREATE INDEX idx_cartitems_user_id ON cartitems(user_id);
CREATE INDEX idx_cartitems_product_id ON cartitems(product_id);

-- Insert your existing cart data back if needed
-- You can replace the values with your actual data if needed
-- INSERT INTO cartitems (user_id, product_id, quantity) VALUES (1, 1, 1);

-- Modify the cartitems table to fix the structure
ALTER TABLE `cartitems` CHANGE `cart_item_id` `cart_id` int(11) NOT NULL AUTO_INCREMENT;

-- If the above doesn't work (due to constraints), use this alternative approach:
-- 1. Drop the existing cartitems table (backup your data if needed)
-- DROP TABLE IF EXISTS cartitems;
-- 
-- 2. Recreate the cartitems table with the correct structure
-- CREATE TABLE cartitems (
--   cart_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
--   user_id INT NOT NULL,
--   product_id INT NOT NULL,
--   quantity INT NOT NULL,
--   FOREIGN KEY (user_id) REFERENCES users(user_id),
--   FOREIGN KEY (product_id) REFERENCES products(product_id)
-- );
-- 
-- 3. Create indexes for better performance
-- CREATE INDEX idx_cartitems_user_id ON cartitems(user_id);
-- CREATE INDEX idx_cartitems_product_id ON cartitems(product_id); 