<?php
include 'db.php';


$session_id = $_GET['session_id'];

$sql = "DELETE FROM READING_SESSION WHERE session_id = $session_id";

if (mysqli_query($conn, $sql)) {
    echo 1;
} else {
    echo 0;
}

mysqli_close($conn);
?>
