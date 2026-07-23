<?php
include 'db.php';

$user_book_id = $_GET['user_book_id'];

$sql = "UPDATE USER_BOOK 
        SET end_date = NOW()
        WHERE user_book_id = $user_book_id";

mysqli_query($conn, $sql);
mysqli_close($conn);
?>
