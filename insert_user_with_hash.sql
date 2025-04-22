-- Insert a user named Shah with username 'shah' and properly hashed password 'shah'
-- The format of the hashed password is 'salt:hashedPassword' where both are Base64 encoded

INSERT INTO `users` (`username`, `password`, `role`, `is_approved`, `name`, `contact_number`, `email`) 
VALUES ('shah', 'L98wPQtqYFAA6sFx0gLLog==:9Fq52GKqhqEH8CQwPyOlBk1dpkiinT7RCWjNN+T48VA=', 'customer', 1, 'Shah', '1234567890', 'shah@example.com');

-- Note: This uses a pre-computed hash for the password 'shah' that follows the format used by 
-- the PasswordUtil.hashPasswordWithSalt() method in your application
-- In a typical scenario, you would use the UserDAO.createUser() method instead which 
-- automatically handles password hashing 