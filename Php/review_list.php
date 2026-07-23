<?php
$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);
if(!$conn){
    echo json_encode(["success" => false, "message" => "mySQL 접속 오류"]);
    exit;
}
mysqli_set_charset($conn, "utf8");

$book_id = $_POST['book_id'] ?? '';

$query = "
    SELECT 
        REVIEW.review_id,
        REVIEW.content,
        REVIEW.update_date,
        USER_BOOK.start_date,
        USER_BOOK.end_date,
        USERS.nickname,
        USERS.profile_image_url,
        (
            SELECT COUNT(*)
            FROM REVIEW_LIKE RL
            WHERE RL.review_id = REVIEW.review_id
              AND RL.status = 0
        ) AS likes_count
    FROM REVIEW
    JOIN USER_BOOK ON REVIEW.user_book_id = USER_BOOK.user_book_id
    JOIN USERS     ON USER_BOOK.user_id   = USERS.user_id
    WHERE USER_BOOK.book_id = '$book_id'
      AND REVIEW.visibility = 0   -- 0 = 전체공개
      AND REVIEW.status     = 0   -- 보이는 리뷰만
    ORDER BY likes_count DESC, update_date DESC
";

$result  = mysqli_query($conn, $query);
$reviews = [];

while ($row = mysqli_fetch_assoc($result)) {
    $reviews[] = $row;
}

echo json_encode(["success" => true, "reviews" => $reviews], JSON_UNESCAPED_UNICODE);

mysqli_close($conn);
?>