DROP DATABASE IF EXISTS fleetflow;
CREATE DATABASE fleetflow;
USE fleetflow;

-- ---------------- ROLES ----------------
CREATE TABLE roles (
 id INT AUTO_INCREMENT PRIMARY KEY,+
 name VARCHAR(50) UNIQUE,
 description VARCHAR(255),
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(150),
 email VARCHAR(255) UNIQUE,
 password_hash VARCHAR(255),
 status ENUM('active','disabled','locked') DEFAULT 'active',
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_roles (
 user_id INT,
 role_id INT,
 PRIMARY KEY(user_id,role_id),
 FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

INSERT INTO roles(name) VALUES
('admin'),('manager'),('dispatcher'),('safety'),('analyst');

-- ---------------- VEHICLE TYPES ----------------
CREATE TABLE vehicle_types(
 id INT AUTO_INCREMENT PRIMARY KEY,
 type_name VARCHAR(50) UNIQUE
);

INSERT INTO vehicle_types(type_name) VALUES ('truck'),('van'),('bike');

-- ---------------- VEHICLES ----------------
CREATE TABLE vehicles(
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(120),
 model VARCHAR(120),
 plate_number VARCHAR(30) UNIQUE,
 vehicle_type_id INT,
 capacity_kg INT,
 odometer BIGINT DEFAULT 0,
 status ENUM('available','on_trip','in_shop','retired') DEFAULT 'available',
 acquisition_cost DECIMAL(12,2) DEFAULT 0,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(vehicle_type_id) REFERENCES vehicle_types(id)
);

-- ---------------- DRIVERS ----------------
CREATE TABLE drivers(
 id INT AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(150),
 phone VARCHAR(40),
 license_number VARCHAR(80) UNIQUE,
 license_expiry DATE,
 status ENUM('on_duty','off_duty','suspended') DEFAULT 'off_duty'
);

-- ---------------- TRIPS ----------------
CREATE TABLE trips(
 id INT AUTO_INCREMENT PRIMARY KEY,
 trip_code VARCHAR(80) UNIQUE,
 vehicle_id INT,
 driver_id INT,
 cargo_weight INT,
 origin VARCHAR(255),
 destination VARCHAR(255),
 start_time DATETIME,
 end_time DATETIME,
 status ENUM('draft','dispatched','completed','cancelled') DEFAULT 'draft',
 FOREIGN KEY(vehicle_id) REFERENCES vehicles(id),
 FOREIGN KEY(driver_id) REFERENCES drivers(id)
);

-- ---------------- MAINTENANCE ----------------
CREATE TABLE maintenance_logs(
 id INT AUTO_INCREMENT PRIMARY KEY,
 vehicle_id INT,
 description TEXT,
 cost DECIMAL(12,2),
 service_date DATE,
 FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

-- ---------------- FUEL ----------------
CREATE TABLE fuel_logs(
 id INT AUTO_INCREMENT PRIMARY KEY,
 vehicle_id INT,
 liters DECIMAL(10,2),
 cost DECIMAL(12,2),
 log_date DATE,
 FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

-- ---------------- EXPENSES ----------------
CREATE TABLE expenses(
 id INT AUTO_INCREMENT PRIMARY KEY,
 vehicle_id INT,
 trip_id INT NULL,
 amount DECIMAL(12,2),
 type VARCHAR(50),
 expense_date DATE,
 FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
 FOREIGN KEY(trip_id) REFERENCES trips(id) ON DELETE SET NULL
);

-- ---------------- DRIVER SCORES ----------------
CREATE TABLE driver_scores(
 driver_id INT PRIMARY KEY,
 safety_score DECIMAL(5,2) DEFAULT 100,
 completion_rate DECIMAL(5,2) DEFAULT 100,
 FOREIGN KEY(driver_id) REFERENCES drivers(id) ON DELETE CASCADE
);

-- ---------------- ANALYTICS CACHE ----------------
CREATE TABLE analytics_cache(
 vehicle_id INT PRIMARY KEY,
 total_cost DECIMAL(14,2) DEFAULT 0,
 total_distance BIGINT DEFAULT 0,
 fuel_efficiency DECIMAL(10,3) DEFAULT 0,
 roi DECIMAL(10,3) DEFAULT 0,
 FOREIGN KEY(vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

-- ---------------- INDEXES ----------------
CREATE INDEX idx_vehicle_status ON vehicles(status);
CREATE INDEX idx_trip_status ON trips(status);
CREATE INDEX idx_driver_status ON drivers(status);

-- ---------------- TRIGGERS ----------------
DELIMITER //

CREATE TRIGGER trip_capacity_check
BEFORE INSERT ON trips
FOR EACH ROW
BEGIN
 DECLARE maxcap INT;
 SELECT capacity_kg INTO maxcap FROM vehicles WHERE id = NEW.vehicle_id;
 IF NEW.cargo_weight > maxcap THEN
  SIGNAL SQLSTATE '45000'
  SET MESSAGE_TEXT = 'Cargo exceeds vehicle capacity';
 END IF;
END//

CREATE TRIGGER maintenance_auto_status
AFTER INSERT ON maintenance_logs
FOR EACH ROW
BEGIN
 UPDATE vehicles SET status='in_shop' WHERE id=NEW.vehicle_id;
END//

CREATE TRIGGER trip_status_update
AFTER UPDATE ON trips
FOR EACH ROW
BEGIN
 IF NEW.status='completed' THEN
  UPDATE vehicles SET status='available' WHERE id=NEW.vehicle_id;
  UPDATE drivers SET status='off_duty' WHERE id=NEW.driver_id;
 END IF;

 IF NEW.status='dispatched' THEN
  UPDATE vehicles SET status='on_trip' WHERE id=NEW.vehicle_id;
  UPDATE drivers SET status='on_duty' WHERE id=NEW.driver_id;
 END IF;
END//

DELIMITER ;

-- ---------------- DEFAULT ADMIN ----------------
INSERT INTO users(name,email,password_hash)
VALUES ('Admin','admin@local','admin123');

INSERT INTO user_roles(user_id,role_id)
SELECT u.id,r.id
FROM users u,roles r
WHERE u.email='admin@local' AND r.name='admin';