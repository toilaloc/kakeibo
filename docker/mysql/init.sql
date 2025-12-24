-- create test database
CREATE DATABASE IF NOT EXISTS kakeibo_test
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

-- grant permissions
GRANT ALL PRIVILEGES ON kakeibo_development.* TO 'kakeibo_user'@'%';
GRANT ALL PRIVILEGES ON kakeibo_test.* TO 'kakeibo_user'@'%';

FLUSH PRIVILEGES;
