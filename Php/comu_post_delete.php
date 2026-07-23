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

$success = true;

$query_comments = "DELETE FROM POST_COMMENT WHERE post_id = $post_id";
if (!$conn->query($query_comments)) {
    $success = false;
    $error_message = "댓글 삭제 실패: " . $conn->error;
}

if ($success) {
    $query_likes = "DELETE FROM POST_LIKE WHERE post_id = $post_id";
    if (!$conn->query($query_likes)) {
        $success = false;
        $error_message = "좋아요 기록 삭제 실패: " . $conn->error;
    }
}

if ($success) {
    $query_post = "DELETE FROM COMMUNITY_POST WHERE post_id = $post_id AND user_id = $user_id"; 
    
    if ($conn->query($query_post) === TRUE) {
        if ($conn->affected_rows === 0) {
            $success = false;
            $error_message = "삭제 권한 없음";
        }
    } else {
        $success = false;
        $error_message = "게시글 삭제 실패: " . $conn->error;
    }
}

if ($success) {
    echo json_encode(["result" => "success"]);
} else {
    echo json_encode(["result" => "error", "message" => $error_message ?? "알 수 없는 오류"]);
}

$conn->close();
?>