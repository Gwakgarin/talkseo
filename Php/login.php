<?php

include 'db.php';

$id = $_POST['id'] ?? '';
$pwd = $_POST['pwd'] ?? '';

if (!$conn) {
    echo "0";
    exit;
}


$sql = "SELECT user_id FROM USERS WHERE id='$id' AND password='$pwd';";
$result = mysqli_query($conn, $sql);

$pkeyValue = 0;

if ($result && mysqli_num_rows($result) > 0) {
    $row = mysqli_fetch_assoc($result);
    if (isset($row["user_id"])) {
        $pkeyValue = $row["user_id"];
    }
}

echo $pkeyValue;
?>
