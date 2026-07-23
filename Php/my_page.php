<?php
include 'db.php';
mysqli_set_charset($conn, "utf8");

$user_id = $_GET['user_id'];

$data = '{';

// 프로필
$sql = "SELECT nickname, email FROM USERS WHERE user_id = $user_id";
$res = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($res);

$data .= '"nickname":"' . ($row['nickname'] ?? '') . '",';
$data .= '"email":"' . ($row['email'] ?? '') . '",';





// 완독한 책 목록
$sql = "
    SELECT user_book_id, book_id
    FROM USER_BOOK
    WHERE user_id = $user_id
      AND end_date IS NOT NULL
    ORDER BY user_book_id DESC
";
$res = mysqli_query($conn, $sql);

$data .= '"books":[';

$cnt = 0;
while ($row = mysqli_fetch_assoc($res)) {

    if ($cnt > 0) { $data .= ','; }
    $cnt++;

    $user_book_id = $row['user_book_id'];
    $book_id = $row['book_id'];

    // 책 정보
    $q1 = "SELECT title, cover_image_url FROM BOOK WHERE book_id = $book_id";
    $r1 = mysqli_query($conn, $q1);
    $b = mysqli_fetch_assoc($r1);

    // 저자 정보
    $q2 = "SELECT name FROM BOOK_AUTHOR WHERE book_id = $book_id LIMIT 1";
    $r2 = mysqli_query($conn, $q2);
    $a = mysqli_fetch_assoc($r2);

    $title = $b['title'] ?? '';
    $cover = $b['cover_image_url'] ?? '';
    $author = $a['name'] ?? '';

    $data .= '{';
    $data .= '"user_book_id":"' . $user_book_id . '",';
    $data .= '"title":"' . $title . '",';
    $data .= '"author":"' . $author . '",';
    $data .= '"cover":"' . $cover . '"';
    $data .= '}';
}

$data .= ']';
$data .= '}';

echo $data;

mysqli_close($conn);
?>
