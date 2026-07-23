<?php
include 'db.php';


$session_id = $_GET['session_id'];
$reading_time = $_GET['reading_time'];
$end_page = $_GET['end_page'];

$sql = "UPDATE READING_SESSION 
        SET reading_time = $reading_time, end_page = $end_page
        WHERE session_id = $session_id";

if (mysqli_query($conn, $sql)) {
    echo 1;
} else {
    echo 0;
}

mysqli_close($conn);
?>
