<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

$scoresFile = 'scores.json';

// Initialize file if it doesn't exist
if (!file_exists($scoresFile)) {
    file_put_contents($scoresFile, json_encode([]));
}

// Handle GET request - retrieve high scores
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    $game = isset($_GET['game']) ? $_GET['game'] : null;
    $scores = json_decode(file_get_contents($scoresFile), true);

    if ($game) {
        // Return scores for specific game
        $gameScores = isset($scores[$game]) ? $scores[$game] : [];
        // Sort by score descending and return top 10
        usort($gameScores, function($a, $b) {
            return $b['score'] - $a['score'];
        });
        echo json_encode(array_slice($gameScores, 0, 10));
    } else {
        // Return all scores
        echo json_encode($scores);
    }
    exit;
}

// Handle POST request - submit new score
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents('php://input'), true);

    if (!isset($data['game']) || !isset($data['username']) || !isset($data['score'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields']);
        exit;
    }

    $game = $data['game'];
    $username = substr(trim($data['username']), 0, 20); // Limit username length
    $score = intval($data['score']);

    // Sanitize username
    $username = htmlspecialchars($username, ENT_QUOTES, 'UTF-8');

    if (empty($username)) {
        http_response_code(400);
        echo json_encode(['error' => 'Username cannot be empty']);
        exit;
    }

    // Load existing scores
    $scores = json_decode(file_get_contents($scoresFile), true);

    if (!isset($scores[$game])) {
        $scores[$game] = [];
    }

    // Add new score
    $scores[$game][] = [
        'username' => $username,
        'score' => $score,
        'timestamp' => time()
    ];

    // Keep only top 100 scores per game to prevent file from growing too large
    usort($scores[$game], function($a, $b) {
        return $b['score'] - $a['score'];
    });
    $scores[$game] = array_slice($scores[$game], 0, 100);

    // Save scores
    file_put_contents($scoresFile, json_encode($scores, JSON_PRETTY_PRINT));

    echo json_encode(['success' => true]);
    exit;
}

http_response_code(405);
echo json_encode(['error' => 'Method not allowed']);
?>
