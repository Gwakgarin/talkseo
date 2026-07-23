<?php
$post_id = $_POST["post_id"];

$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);
if ($conn->connect_error) {
    echo '{"POST_COMMENT":[]}';
    exit;
}

$query = "
SELECT 
    POST_COMMENT.post_comment_id,
    USERS.user_id,
    USERS.nickname,
    USERS.profile_image_url,
    POST_COMMENT.content,
    POST_COMMENT.insert_date,
    POST_COMMENT.parent_comment_id
FROM POST_COMMENT
LEFT JOIN USERS ON USERS.user_id = POST_COMMENT.user_id
WHERE POST_COMMENT.post_id = $post_id
";

$result = mysqli_query($conn, $query);

$posts = [];
while($row = mysqli_fetch_assoc($result)) {
    $posts[] = [
        "post_comment_id" => (int)$row['post_comment_id'],
        "user_id" => $row['user_id'],
        "nickname" => $row['nickname'],
        "profile_image_url" => $row['profile_image_url'],
        "content" => $row['content'],
        "insert_date" => $row['insert_date'],
        "parent_comment_id" => (int)$row['parent_comment_id']
    ];
}

echo json_encode(["POST_COMMENT"=>$posts], JSON_UNESCAPED_UNICODE);

mysqli_close($conn);
?>
