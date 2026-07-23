<?php
include 'db.php';

$user_book_id = $_GET['user_book_id'];


$sql = "INSERT INTO READING_SESSION (user_book_id, session_date, reading_time, start_page, end_page)
        VALUES ($user_book_id, NOW(), 0, 0, 0)";



mysqli_query($conn, $sql);
echo $conn->insert_id;

mysqli_close($conn);

?>