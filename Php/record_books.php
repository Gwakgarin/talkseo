<?php
include 'db.php';

$user_id = $_GET['user_id'];

$sql = "SELECT 
            USER_BOOK.user_book_id,
            USER_BOOK.current_page,
            BOOK.title,
            BOOK.cover_image_url,
            BOOK.total_pages,
            BOOK_AUTHOR.name AS author_name
        FROM USER_BOOK
        JOIN BOOK ON USER_BOOK.book_id = BOOK.book_id
        JOIN BOOK_AUTHOR ON BOOK.book_id = BOOK_AUTHOR.book_id
        WHERE USER_BOOK.user_id = $user_id
        ORDER BY USER_BOOK.user_book_id DESC";

$result = mysqli_query($conn, $sql);

$data = '{"books":[';
$cnt = 0;

while ($row = mysqli_fetch_array($result)) {

    $cnt++;

    if ($cnt != 1) {
        $data .= ',';
    }

    $data .= '{' .
        '"user_book_id":"' . $row['user_book_id'] . '",' .
        '"title":"' . $row['title'] . '",' .
        '"author":"' . $row['author_name'] . '",' .
        '"cover_image_url":"' . $row['cover_image_url'] . '",' .
        '"total_pages":"' . $row['total_pages'] . '",' .
        '"current_page":"' . $row['current_page'] . '"' .
    '}';
}

$data .= ']}';

echo $data;

mysqli_close($conn);
?>
