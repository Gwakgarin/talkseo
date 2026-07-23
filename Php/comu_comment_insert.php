<?php
$user_id = $_POST["user_id"];
$post_id = $_POST["post_id"];
$content = $_POST["content"];  
$parent_comment_id = isset($_POST["parent_comment_id"]) ? (int)$_POST["parent_comment_id"] : 0;


$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);

if ($conn->connect_error) {
    echo json_encode(["result" => "error", "message" => "DB connection failed"]);
    exit;
}

$query = "INSERT INTO POST_COMMENT (user_id, post_id, content, insert_date, parent_comment_id)
VALUES ('$user_id', '$post_id', '$content', NOW(), $parent_comment_id)";

if ($conn->query($query) === TRUE) {
    echo json_encode(["result" => "success"]);
} else {
    echo json_encode(["result" => "error", "message" => $conn->error]);
}

$conn->close();
?>
