<?php
include 'db.php';

$user_id = $_GET['user_id'];

$sql = "SELECT USER_BOOK.user_book_id, BOOK.title,
    COALESCE(SUM(READING_SESSION.reading_time), 0) AS today_total_time
    FROM USER_BOOK
    JOIN BOOK ON USER_BOOK.book_id = BOOK.book_id
    LEFT JOIN READING_SESSION 
    ON READING_SESSION.user_book_id = USER_BOOK.user_book_id
    AND DATE(READING_SESSION.session_date) = CURDATE()
    WHERE USER_BOOK.user_id = $user_id AND USER_BOOK.current_page < BOOK.total_pages
    GROUP BY USER_BOOK.user_book_id
    ORDER BY USER_BOOK.user_book_id ASC";

    
$result = mysqli_query($conn, $sql);

$data = '{"today_books":[';
$cnt = 0;

while ($row = mysqli_fetch_array($result)) {
    $cnt++;
    if ($cnt != 1) $data .= ',';
    $data .= '{"user_book_id":"'.$row['user_book_id'].'",'.
              '"title":"'.$row['title'].'",'.
              '"today_total_time":"'.$row['today_total_time'].'"}';
}

$data .= ']}';
echo $data;

mysqli_close($conn);
?>
