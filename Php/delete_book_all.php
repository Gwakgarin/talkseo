<?php
include 'db.php';

$user_book_id = $_GET['user_book_id'] ?? 0;

$delete_sessions = "DELETE FROM READING_SESSION WHERE user_book_id = $user_book_id";
$delete_user_book = "DELETE FROM USER_BOOK WHERE user_book_id = $user_book_id";

$ok1 = mysqli_query($conn, $delete_sessions);
$ok2 = mysqli_query($conn, $delete_user_book);

if ($ok1 && $ok2) {
    echo 1;
} else {
    echo 0;
}

mysqli_close($conn);
?>
