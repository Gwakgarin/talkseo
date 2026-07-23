<?php
$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";


$conn = new mysqli($host, $user, $pw, $dbName);
if(!$conn){
    echo "mySQL 접속 오류";
    return;
}
mysqli_set_charset($conn, "utf8"); // 한글 깨짐 방지

$user_id = $_POST['user_id'];
$user_book_id = $_POST['user_book_id'];

// 1. user_book_id를 꼭 같이 가져와야 합니다. (나중에 수정할 때 필요함)
// 2. mysqli_fetch_assoc을 사용하여 불필요한 숫자 인덱스를 제거합니다.
$query = " 
    SELECT 
        USER_BOOK.user_book_id,
        USER_BOOK.start_date,
        USER_BOOK.end_date,
        REVIEW.content,
        REVIEW.is_spoiler,
        REVIEW.visibility
    FROM USER_BOOK
    LEFT JOIN REVIEW ON USER_BOOK.user_book_id = REVIEW.user_book_id
    WHERE USER_BOOK.user_id = '$user_id' AND USER_BOOK.user_book_id = '$user_book_id'
";

$result = mysqli_query($conn, $query);

if ($result && mysqli_num_rows($result) > 0) {
    // 연관 배열(key-value) 형태로 가져오기
    $row = mysqli_fetch_assoc($result);
    
    // JSON 응답 생성
    echo json_encode(array(
        "success" => true,
        "user_book_id" => $row['user_book_id'],
        "start_date" => $row['start_date'],
        "end_date" => $row['end_date'],

        "content" => $row['content'], 
        "visibility" => $row['visibility'],
        "is_spoiler" => $row['is_spoiler']
    ));
} else {

    echo json_encode(array(
        "success" => false,
        "message" => "기록이 없습니다."
    ));
}

mysqli_close($conn);
?>