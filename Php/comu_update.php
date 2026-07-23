<?php
$post_id = isset($_POST["post_id"]) ? (int)$_POST["post_id"] : 0;
$user_id = isset($_POST["user_id"]) ? (int)$_POST["user_id"] : 0; 

$title = $_POST["title"];
$content = $_POST["content"];

$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);

if ($conn->connect_error) {
    echo json_encode(["result" => "error", "message" => "DB connection failed"]);
    exit;
}
$query = "UPDATE COMMUNITY_POST 
          SET title = '$title', content = '$content', update_date = NOW() 
          WHERE post_id = $post_id AND user_id = $user_id";


if ($conn->query($query) === TRUE) {
    if ($conn->affected_rows > 0) {
        echo json_encode(["result" => "success", "post_id" => $post_id]);
    } else {
        echo json_encode(["result" => "error", "message" => "수정 권한 없음 또는 게시글 ID 오류"]);
    }
} else {
    echo json_encode(["result" => "error", "message" => $conn->error]);
}

$conn->close();
?>