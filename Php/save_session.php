<?php 

include 'db.php';


$session_id = $_GET['session_id'] ;
$end_page   = $_GET['end_page'] ;


$sql = "UPDATE READING_SESSION SET end_page = $end_page WHERE session_id = $session_id";
mysqli_query($conn, $sql);

$sql2 = "UPDATE USER_BOOK 
         JOIN READING_SESSION ON USER_BOOK.user_book_id = READING_SESSION.user_book_id 
         SET USER_BOOK.current_page = $end_page 
         WHERE READING_SESSION.session_id = $session_id";

mysqli_query($conn, $sql2);

echo "1";

mysqli_close($conn);
?>