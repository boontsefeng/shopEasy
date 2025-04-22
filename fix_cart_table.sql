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
INSERT INTO cartitems (user_id, product_id, quantity) VALUES (12, 3, 1); 