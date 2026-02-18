-- Create users table for authentication
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    gender VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Optional: Add index on email for faster lookups
CREATE INDEX idx_email ON users(email);


CREATE TABLE workouts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    photo VARCHAR(255),
    duration INT,
    difficulty VARCHAR(50),
    muscle_groups VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    workout_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    image VARCHAR(255),
    FOREIGN KEY (workout_id) 
        REFERENCES workouts(id) 
        ON DELETE CASCADE
);


CREATE TABLE workout_sets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    workout_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    FOREIGN KEY (workout_id) 
        REFERENCES workouts(id) 
        ON DELETE CASCADE
);


CREATE TABLE exercises (
    id INT AUTO_INCREMENT PRIMARY KEY,
    set_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    value VARCHAR(50),
    image VARCHAR(255),
    FOREIGN KEY (set_id) 
        REFERENCES workout_sets(id) 
        ON DELETE CASCADE
);


CREATE TABLE workout_schedules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  workout_id INT NOT NULL,
  scheduled_date DATE NOT NULL,
  scheduled_time TIME NOT NULL,
  duration INT,
  difficulty VARCHAR(50),
  repetitions INT,
  weights VARCHAR(100),
  status ENUM('scheduled', 'completed', 'cancelled') DEFAULT 'scheduled',
  completed_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (workout_id) REFERENCES workouts(id) ON DELETE CASCADE,
  INDEX idx_scheduled_date (scheduled_date),
  INDEX idx_user_date (user_id, scheduled_date)
);


CREATE TABLE IF NOT EXISTS progress_photos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  photo VARCHAR(255) NOT NULL,
  taken_at DATE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_taken_at (taken_at),
  INDEX idx_user_taken (user_id, taken_at)
);


-- Devices for health data sources (phone sensors, smartwatches, etc.)
CREATE TABLE IF NOT EXISTS devices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_uuid VARCHAR(255) NOT NULL,
  source ENUM('google_fit', 'healthkit', 'wear_os', 'watch_os', 'manual', 'other') DEFAULT 'other',
  platform VARCHAR(50),
  model VARCHAR(100),
  last_seen_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_user_device (user_id, device_uuid),
  INDEX idx_devices_user (user_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


-- Daily aggregates for dashboard
CREATE TABLE IF NOT EXISTS health_daily (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_id INT NOT NULL,
  source ENUM('google_fit', 'healthkit', 'wear_os', 'watch_os', 'manual', 'other') DEFAULT 'other',
  date DATE NOT NULL,
  timezone VARCHAR(50),
  steps INT,
  calories DOUBLE,
  distance_m DOUBLE,
  active_minutes INT,
  sleep_minutes INT,
  heart_rate_avg INT,
  heart_rate_min INT,
  heart_rate_max INT,
  water_ml INT,
  weight_kg DECIMAL(5,2),
  bmi DECIMAL(5,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_daily (user_id, device_id, source, date),
  INDEX idx_health_user_date (user_id, date),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);


-- Time-series samples for charts
CREATE TABLE IF NOT EXISTS health_samples (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  device_id INT NOT NULL,
  source ENUM('google_fit', 'healthkit', 'wear_os', 'watch_os', 'manual', 'other') DEFAULT 'other',
  metric ENUM('heart_rate', 'steps', 'calories', 'distance', 'active_minutes', 'sleep', 'water', 'weight', 'bmi') NOT NULL,
  value DOUBLE NOT NULL,
  unit VARCHAR(20),
  recorded_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_samples_user_metric_time (user_id, metric, recorded_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);
