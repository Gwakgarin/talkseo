<?php
include 'db.php';

$user_id = $_POST['user_id'] ?? $_GET['user_id'] ?? null;
$book_id = $_POST['book_id'] ?? $_GET['book_id'] ?? null;

if (!$user_id || !$book_id) {
    echo json_encode(["status" => "error", "message" => "Missing user_id or book_id"]);
    exit;
}

$sql = "INSERT INTO USER_BOOK (user_id, book_id, current_page, start_date)
        VALUES ($user_id, $book_id, 0, NOW())";

if (mysqli_query($conn, $sql)) {
    echo json_encode([
        "status" => "success",
        "user_book_id" => mysqli_insert_id($conn)
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => mysqli_error($conn)
    ]);
}

mysqli_close($conn);
?>
