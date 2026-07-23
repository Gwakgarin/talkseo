<?php
include 'db.php';


$session_id = $_GET['session_id']; 


$sql = " SELECT READING_SESSION.session_date, READING_SESSION.reading_time, 
    USER_BOOK.current_page, BOOK.total_pages, BOOK.title, BOOK.cover_image_url
    FROM READING_SESSION
    JOIN USER_BOOK ON READING_SESSION.user_book_id = USER_BOOK.user_book_id
    JOIN BOOK ON USER_BOOK.book_id = BOOK.book_id
    WHERE READING_SESSION.session_id = $session_id
";

$result = mysqli_query($conn, $sql);

$data = '{"sessions":[';
$cnt = 0;

while ($row = mysqli_fetch_array($result)) {
    $cnt = $cnt + 1;

    if ($cnt != 1) {
        $data = $data . ',';
    }

    $data = $data .
        '{"session_date":"' . $row['session_date'] . '",' .
        '"reading_time":"' . $row['reading_time'] . '",' .
        '"current_page":"' . $row['current_page'] . '",' .
        '"total_pages":"' . $row['total_pages'] . '",' .
        '"title":"' . $row['title'] . '",' .
        '"cover_image_url":"' . $row['cover_image_url'] . '"}';
}

$data = $data . ']}';

echo $data;

mysqli_close($conn);

?>