-- student_database.sql
-- Complete relational schema for a Student Records & Course Management System
-- Drop and recreate database
DROP DATABASE IF EXISTS student_db;
CREATE DATABASE student_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE student_db;

-- Table: users (system users)
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','lecturer','registrar') NOT NULL DEFAULT 'registrar',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: departments
CREATE TABLE departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL UNIQUE,
  description TEXT
) ENGINE=InnoDB;

-- Table: lecturers
CREATE TABLE lecturers (
  lecturer_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT DEFAULT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(150) UNIQUE,
  phone VARCHAR(30),
  department_id INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_lecturer_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  CONSTRAINT fk_lecturer_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Table: students
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  date_of_birth DATE,
  gender ENUM('female','male','other') DEFAULT 'female',
  email VARCHAR(150),
  phone VARCHAR(30),
  address TEXT,
  enrollment_date DATE DEFAULT (CURRENT_DATE),
  department_id INT,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_student_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  UNIQUE KEY unique_student_contact (email, phone)
) ENGINE=InnoDB;

-- Table: courses
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL UNIQUE,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  credits INT NOT NULL,
  department_id INT,
  lecturer_id INT,
  CONSTRAINT fk_course_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
  CONSTRAINT fk_course_lecturer FOREIGN KEY (lecturer_id) REFERENCES lecturers(lecturer_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Many-to-Many: enrollments (students ↔ courses)
CREATE TABLE enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  enrollment_date DATE DEFAULT (CURRENT_DATE),
  grade ENUM('A','B','C','D','E','F','I','W') DEFAULT NULL,
  CONSTRAINT fk_enrollment_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  CONSTRAINT fk_enrollment_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
  UNIQUE KEY unique_enrollment (student_id, course_id)
) ENGINE=InnoDB;

-- Table: exams
CREATE TABLE exams (
  exam_id INT AUTO_INCREMENT PRIMARY KEY,
  course_id INT NOT NULL,
  exam_date DATE NOT NULL,
  exam_type ENUM('midterm','final','quiz','project') NOT NULL,
  max_score INT NOT NULL DEFAULT 100,
  CONSTRAINT fk_exam_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table: exam_results
CREATE TABLE exam_results (
  result_id INT AUTO_INCREMENT PRIMARY KEY,
  exam_id INT NOT NULL,
  student_id INT NOT NULL,
  score INT NOT NULL,
  CONSTRAINT fk_result_exam FOREIGN KEY (exam_id) REFERENCES exams(exam_id) ON DELETE CASCADE,
  CONSTRAINT fk_result_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  UNIQUE KEY unique_result (exam_id, student_id)
) ENGINE=InnoDB;

-- Table: attendance
CREATE TABLE attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  status ENUM('present','absent','late','excused') NOT NULL DEFAULT 'present',
  CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
  CONSTRAINT fk_attendance_course FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
  UNIQUE KEY unique_attendance (student_id, course_id, attendance_date)
) ENGINE=InnoDB;

-- Table: fees
CREATE TABLE fees (
  fee_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  due_date DATE NOT NULL,
  status ENUM('unpaid','partial','paid') NOT NULL DEFAULT 'unpaid',
  issued_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_fee_student FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table: payments
CREATE TABLE payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  fee_id INT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method ENUM('cash','card','mpesa','bank_transfer') DEFAULT 'cash',
  paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_fee FOREIGN KEY (fee_id) REFERENCES fees(fee_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Seed data
INSERT INTO departments (name, description) VALUES
  ('Computer Science','Computer science department'),
  ('Mathematics','Mathematics department'),
  ('Business','Business studies department');

INSERT INTO users (username, password_hash, role) VALUES
  ('admin','<hash_placeholder>','admin');

-- End of schema