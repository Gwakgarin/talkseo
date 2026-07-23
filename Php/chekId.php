<?php

include 'db.php';

$sql = "select * from USERS where id='".$id."' and password='".$pwd."';";

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
