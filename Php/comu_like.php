<?php
$user_id = $_POST["user_id"];
$post_id = $_POST["post_id"];

$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

$conn = new mysqli($host, $user, $pw, $dbName);

if($conn){
} else {
    echo "접속 실패 <br>";
    return;
}

$sql = "SELECT COUNT(post_id) AS is_liked_by_me FROM POST_LIKE WHERE post_id = $post_id AND user_id = $user_id";

$result = mysqli_query($conn, $sql);

$pkeyValue = 0;

if ($result && mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    if (isset($row["is_liked_by_me"])) {
        $pkeyValue = $row["is_liked_by_me"];
    }
}

if ($pkeyValue == 1) {
    $toggle_sql = "DELETE FROM POST_LIKE WHERE post_id = $post_id AND user_id = $user_id";
    $result_toggle = mysqli_query($conn, $toggle_sql);
    
    if ($result_toggle) {
        $pkeyValue = 0;
    }
    
} else {
    $toggle_sql = "INSERT INTO POST_LIKE (post_id, user_id, insert_date) VALUES ($post_id, $user_id, NOW())";
    $result_toggle = mysqli_query($conn, $toggle_sql);
    
    if ($result_toggle) {
        $pkeyValue = 1;
    }
}

echo $pkeyValue;
?>