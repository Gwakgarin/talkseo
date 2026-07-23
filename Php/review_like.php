<?php
$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);
if(!$conn){
    echo json_encode(["success" => false, "message" => "DB 연결 실패"]);
    exit;
}
mysqli_set_charset($conn, "utf8");

$review_id = $_POST['review_id'] ?? '';
$user_id   = $_POST['user_id'] ?? '';   

if ($review_id === '' || $user_id === '') {
    echo json_encode(["success" => false, "message" => "파라미터 부족"]);
    exit;
}


//좋아요  확인

$checkSql = "
    SELECT review_like_id
    FROM REVIEW_LIKE
    WHERE review_id = '$review_id'
      AND user_id   = '$user_id'
      AND status    = 0
";
$checkResult = mysqli_query($conn, $checkSql);

if (mysqli_num_rows($checkResult) > 0) {
    // 공감 취소: status를 1로 변경
    $row      = mysqli_fetch_assoc($checkResult);
    $likeId   = $row['review_like_id'];

    $updateSql = "
        UPDATE REVIEW_LIKE
        SET status = 1,
            update_date = NOW()
        WHERE review_like_id = '$likeId'
    ";

    $ok = mysqli_query($conn, $updateSql);

    if ($ok) {
        echo json_encode(["success" => true, "mode" => "unlike"]);
    } else {
        echo json_encode(["success" => false, "message" => mysqli_error($conn)]);
    }

} else {
    // 새로 좋아요 
    $insertSql = "
        INSERT INTO REVIEW_LIKE (review_id, user_id, insert_date, status)
        VALUES ('$review_id', '$user_id', NOW(), 0)
    ";

    $ok = mysqli_query($conn, $insertSql);

    if ($ok) {
        echo json_encode(["success" => true, "mode" => "like"]);
    } else {
        echo json_encode(["success" => false, "message" => mysqli_error($conn)]);
    }
}

mysqli_close($conn);
?>

