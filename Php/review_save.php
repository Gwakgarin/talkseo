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

//xcode에서 받아옴
$user_book_id = $_POST['user_book_id'];
$content = $_POST['content'];
$visibility = $_POST['visibility'];
$is_spoiler   = $_POST['is_spoiler']; //0 : spoiler, 1 : not

//status
$status = 0; // 0: 보임 1: 안 보임, 2: 삭제

$start_date = null;
$end_date = null;

$check = "SELECT review_id FROM REVIEW WHERE user_book_id = '$user_book_id'";
$check_result = mysqli_query($conn, $check);



if(mysqli_num_rows($check_result)>0){ //update
    $sql = "UPDATE REVIEW SET 
                content = '$content',
                is_spoiler = '$is_spoiler',
                visibility = '$visibility',
                update_date = NOW(), 
                status = '$status'
            WHERE user_book_id = '$user_book_id'";
    
    $action = "수정";
} else{
    $sql = "INSERT INTO REVIEW (user_book_id, content, is_spoiler, visibility, insert_date, status) 
            VALUES ('$user_book_id', '$content', '$is_spoiler', '$visibility', NOW(), '$status')";
            
    $action = "작성";
}

//쿼리 실행
$result = mysqli_query($conn,$sql);

if($result){
    echo json_encode(array("success" => true, "message" => "감상평 " . $action . " 성공"));
} else {
    echo "Error: " . $action . " 실패: " . mysqli_error($conn);  
}


mysqli_close($conn);

?>