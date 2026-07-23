<?php

$id = $_POST["id"];
$pwd = $_POST["pwd"];
$user_name = $_POST["user_name"];
$email = $_POST["email"];
$phonenum = $_POST["phonenum"];

$host = "localhost";
$user = "root";
$pw = "00000000";
$dbName = "talkseo";


$conn = new mysqli($host, $user, $pw, $dbName);

if($conn){
} else {
    echo "접속 실패 <br>";
    return;
}

$sql = "INSERT INTO `USERS` (`id`, `password`, `name`, `email`, `phone_number`) VALUES ('$id', '$pwd', '$user_name', '$email', '$phonenum')";
$result = mysqli_query($conn, $sql);

$pkeyValue = 0;

if ($result) {
    $pkeyValue = mysqli_insert_id($conn);
    echo "회원가입 성공. PKey: " . $pkeyValue;
} else {
    echo "회원가입 실패. 오류: " . mysqli_error($conn);
}

mysqli_close($conn);
?>