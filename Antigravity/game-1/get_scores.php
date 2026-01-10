<?php
header('Content-Type: application/json');

// Allow CORS
header('Access-Control-Allow-Origin: *');

require 'db.php';

$sql = "SELECT name, score, created_at as date FROM scores ORDER BY score DESC LIMIT 10";
$result = $conn->query($sql);

$scores = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $scores[] = $row;
    }
}

echo json_encode($scores);

$conn->close();
?>
