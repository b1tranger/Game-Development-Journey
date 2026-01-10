<?php
header('Content-Type: application/json');

// Allow CORS for local testing/development
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method Not Allowed']);
    exit;
}

require 'db.php';

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['name']) || !isset($input['score'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid input']);
    exit;
}

$name = substr(strip_tags($input['name']), 0, 50); // Matches VARCHAR(50)
$score = (int)$input['score'];

// Insert new score
$stmt = $conn->prepare("INSERT INTO scores (name, score) VALUES (?, ?)");
$stmt->bind_param("si", $name, $score);

if ($stmt->execute()) {
    // Fetch top 10 scores to return
    $result = $conn->query("SELECT name, score, created_at as date FROM scores ORDER BY score DESC LIMIT 10");
    $scores = [];
    while ($row = $result->fetch_assoc()) {
        $scores[] = $row;
    }
    echo json_encode(['success' => true, 'scores' => $scores]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to save score: ' . $stmt->error]);
}

$stmt->close();
$conn->close();
?>
