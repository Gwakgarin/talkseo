<?php
$post_comment_id = isset($_POST["post_comment_id"]) ? (int)$_POST["post_comment_id"] : 0;
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

$query = "DELETE FROM POST_COMMENT WHERE post_comment_id = $post_comment_id AND user_id = $user_id";

if ($conn->query($query) === TRUE) {
    if ($conn->affected_rows > 0) {
        echo json_encode(["result" => "success"]);
    } else {
        echo json_encode(["result" => "error", "message" => "삭제 권한 없음 또는 댓글 ID 오류 (삭제된 행 0)"]);
    }
} else {
    echo json_encode(["result" => "error", "message" => $conn->error]);
}

$conn->close();
?>