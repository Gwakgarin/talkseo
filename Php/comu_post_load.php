<?php
$post_id = isset($_POST["post_id"]) ? (int)$_POST["post_id"] : 0;
$user_id = isset($_POST["user_id"]) ? (int)$_POST["user_id"] : 0; 

$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    echo json_encode(["result" => "error", "message" => "DB connection failed"]);
    exit;
}

$query = "SELECT title, content 
          FROM COMMUNITY_POST 
          WHERE post_id = $post_id AND user_id = $user_id";

$result = $conn->query($query);

if ($result && $result->num_rows > 0) {
    $row = $result->fetch_assoc();
    
    echo json_encode([
        "result" => "success",
        "post_id" => $post_id,
        "title" => $row['title'],
        "content" => $row['content']
    ], JSON_UNESCAPED_UNICODE);
} else {
    echo json_encode(["result" => "error", "message" => "게시글을 찾을 수 없거나 권한 없음"]);
}

$conn->close();
?>