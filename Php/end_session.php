<?php

include 'db.php';

$session_id = $_GET['session_id'];
$reading_time = $_GET['reading_time'];

$sql = "UPDATE READING_SESSION 
        SET reading_time = $reading_time
        WHERE session_id = $session_id";

mysqli_query($conn, $sql);

mysqli_close($conn);

?>
