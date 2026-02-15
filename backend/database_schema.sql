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
