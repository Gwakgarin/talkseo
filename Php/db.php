<?php

$host ="localhost";
$user = "brant";
$pw = "0505";
$dbName = "talkseo";

// $host ="localhost";
// $user = "root";
// $pw = "12341234";
// $dbName = "talkseo";


$conn = new mysqli($host, $user, $pw, $dbName);


if(!$conn){
   echo "mySQL 접속 오류";
   return;
}

?>