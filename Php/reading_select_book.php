<?php
include 'db.php';

$user_book_id = $_GET['user_book_id'];

$sql = "SELECT USER_BOOK.user_book_id,
               USER_BOOK.current_page,
               USER_BOOK.start_date,
               USER_BOOK.end_date,
               BOOK.title,
               BOOK.total_pages,
               BOOK.cover_image_url,
               READING_SESSION.session_id,
               READING_SESSION.session_date,
               READING_SESSION.start_page,
               READING_SESSION.end_page,
               READING_SESSION.reading_time
        FROM USER_BOOK
        JOIN BOOK ON USER_BOOK.book_id = BOOK.book_id
        LEFT JOIN READING_SESSION ON USER_BOOK.user_book_id = READING_SESSION.user_book_id
        WHERE USER_BOOK.user_book_id = $user_book_id
        ORDER BY READING_SESSION.session_date DESC";

$result = mysqli_query($conn, $sql);

$sessions = [];
$total_time = 0;

while ($row = mysqli_fetch_assoc($result)) {

    $session_id    = intval($row['session_id'] ?? 0);
    $reading_time  = intval($row['reading_time'] ?? 0);
    $start_page    = intval($row['start_page'] ?? 0);
    $end_page      = intval($row['end_page'] ?? 0);
    $session_date  = $row['session_date'] ?? "";

    $total_time += $reading_time;

    $sessions[] = [
        "session_id" => $session_id,
        "title" => $row['title'],
        "cover_image_url" => $row['cover_image_url'],
        "total_pages" => $row['total_pages'],
        "current_page" => $row['current_page'],
        "start_date" => $row['start_date'],
        "end_date" => $row['end_date'],
        "total_reading_time" => (string)$total_time,
        "session_date" => $session_date,
        "reading_time" => (string)$reading_time,
        "start_page" => (string)$start_page,
        "end_page" => (string)$end_page
    ];
}

echo json_encode(["sessions" => $sessions], JSON_UNESCAPED_UNICODE);
mysqli_close($conn);
?>
