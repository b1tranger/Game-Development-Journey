<?php
$host = 'localhost';
$user = 'root';
$pass = '';

// Connect to MySQL server first (no database selected)
$conn = new mysqli($host, $user, $pass);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Create database if not exists
$sql = "CREATE DATABASE IF NOT EXISTS platformer_db";
if ($conn->query($sql) === TRUE) {
    echo "Database created successfully or already exists.<br>";
} else {
    die("Error creating database: " . $conn->error);
}

// Select the database
$conn->select_db('platformer_db');

// Create table if not exists
$sql = "CREATE TABLE IF NOT EXISTS scores (
    id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    score INT(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)";

if ($conn->query($sql) === TRUE) {
    echo "Table 'scores' created successfully or already exists.<br>";
} else {
    echo "Error creating table: " . $conn->error;
}

$conn->close();
?>
