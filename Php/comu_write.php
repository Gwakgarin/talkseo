<?php
$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);

if ($conn->connect_error) {
    die("mySQL 접속 오류: " . $conn->connect_error);
}

error_log("POST: " . print_r($_POST, true));

$user_id = $_POST['user_id'] ?? '';
$title   = $_POST['title']   ?? '';
$content = $_POST['content'] ?? '';


$status = 0; 

$query = "
    INSERT INTO COMMUNITY_POST
    (user_id, title, content, insert_date, update_date, status)
    VALUES
    ('$user_id', '$title', '$content', NOW(), NOW(), '$status')
";

$result = mysqli_query($conn, $query);

if ($result) {
    $inserted_id = mysqli_insert_id($conn); 
    echo json_encode(["result" => "success", "post_id" => (int)$inserted_id]);
} else {
    echo json_encode(["result" => "error", "message" => "쿼리 오류: " . mysqli_error($conn)]);
}

mysqli_close($conn);
?>
