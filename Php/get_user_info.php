<?php
include 'db.php';

$user_id = $_GET['user_id'];

$response = array();

// 닉네임, 이메일
$sql1 = "SELECT nickname, email FROM USERS WHERE user_id = $user_id";
$r1 = mysqli_query($conn, $sql1);
if ($row = mysqli_fetch_assoc($r1)) {
    $response['nickname'] = $row['nickname'];
    $response['email'] = $row['email'];
} else {
    $response['nickname'] = "";
    $response['email'] = "";
}

// 이번 달 독서시간
$sql2 = "SELECT SUM(reading_time) AS monthly
         FROM READING_SESSION
         WHERE user_id = $user_id
         AND MONTH(session_date) = MONTH(CURRENT_DATE())
         AND YEAR(session_date) = YEAR(CURRENT_DATE())";

$r2 = mysqli_query($conn, $sql2);
$row2 = mysqli_fetch_assoc($r2);
$response['monthlyTime'] = intval($row2['monthly'] ?? 0);

// 총 독서 시간
$sql3 = "SELECT SUM(reading_time) AS total
         FROM READING_SESSION
         WHERE user_id = $user_id";

$r3 = mysqli_query($conn, $sql3);
$row3 = mysqli_fetch_assoc($r3);
$response['totalTime'] = intval($row3['total'] ?? 0);

// 완독한 책 개수
$sql4 = "SELECT COUNT(*) AS finished
         FROM USER_BOOK
         WHERE user_id = $user_id
         AND end_date IS NOT NULL";

$r4 = mysqli_query($conn, $sql4);
$row4 = mysqli_fetch_assoc($r4);
$response['completedBooks'] = intval($row4['finished'] ?? 0);

echo json_encode($response, JSON_UNESCAPED_UNICODE);
?>
