<?php
$user_id = $_POST["user_id"];
$post_id = $_POST["post_id"];

$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    echo '{"COMMUNITY_POST":[]}';
    exit;
}

$query = "SELECT USERS.user_id, USERS.nickname, USERS.profile_image_url, 
COMMUNITY_POST.content, COMMUNITY_POST.insert_date, COMMUNITY_POST.post_id, COMMUNITY_POST.title,
(SELECT COUNT(POST_LIKE.post_id) FROM POST_LIKE WHERE POST_LIKE.post_id = COMMUNITY_POST.post_id) AS like_count,
(SELECT COUNT(POST_COMMENT.post_id) FROM POST_COMMENT WHERE POST_COMMENT.post_id = COMMUNITY_POST.post_id) AS comment_count,
(SELECT COUNT(POST_LIKE.post_id) FROM POST_LIKE WHERE POST_LIKE.post_id = COMMUNITY_POST.post_id AND POST_LIKE.user_id = $user_id) AS is_liked_by_me
FROM COMMUNITY_POST
LEFT JOIN USERS ON USERS.user_id = COMMUNITY_POST.user_id
WHERE COMMUNITY_POST.post_id=$post_id";

$result = mysqli_query($conn, $query);

$posts = [];
while($row = mysqli_fetch_assoc($result)) {
    $posts[] = [
        "user_id" => $row['user_id'],
        "nickname" => $row['nickname'],
        "profile_image_url" => $row['profile_image_url'],
        "content" => $row['content'],
        "insert_date" => $row['insert_date'],
        "post_id" => (int)$row['post_id'],
        "title" => $row['title'],
        "like_count" => (int)$row['like_count'],
        "comment_count" => (int)$row['comment_count'],
        "is_liked_by_me" => (int)$row['is_liked_by_me']
    ];
}

echo json_encode(["COMMUNITY_POST"=>$posts], JSON_UNESCAPED_UNICODE);

mysqli_close($conn);
?>
