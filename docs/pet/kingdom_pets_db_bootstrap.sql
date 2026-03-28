-- Kingdom of Pets database bootstrap
-- Execute as MySQL root/admin user.

CREATE DATABASE IF NOT EXISTS `kingdom_pets`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS 'canary'@'127.0.0.1' IDENTIFIED BY '123456789';
CREATE USER IF NOT EXISTS 'canary'@'localhost' IDENTIFIED BY '123456789';

GRANT ALL PRIVILEGES ON `kingdom_pets`.* TO 'canary'@'127.0.0.1';
GRANT ALL PRIVILEGES ON `kingdom_pets`.* TO 'canary'@'localhost';

FLUSH PRIVILEGES;

-- After this, import schema:
-- mysql -u canary -p -h 127.0.0.1 kingdom_pets < schema.sql
