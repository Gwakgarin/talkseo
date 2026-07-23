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

$search = isset($_POST['search']) ? $_POST['search'] : '';

if ($search != "") {
    // 검색어가 있을 때 — 책 제목, 저자, 출판사 중 하나라도 검색어 포함 시
    $query = "SELECT BOOK.cover_image_url, BOOK.book_id, BOOK.title, BOOK_AUTHOR.name as author_name, BOOK_PUBLISHER.name as publisher_name 
              FROM BOOK
              LEFT JOIN BOOK_AUTHOR ON BOOK.book_id = BOOK_AUTHOR.book_id
              LEFT JOIN BOOK_PUBLISHER ON BOOK.book_id = BOOK_PUBLISHER.book_id
              WHERE BOOK.title LIKE '%$search%' 
                 OR BOOK_AUTHOR.name LIKE '%$search%' 
                 OR BOOK_PUBLISHER.name LIKE '%$search%'";
} else {
    // 검색어가 없을 때 — 전체 리스트
    $query = "SELECT BOOK.cover_image_url, BOOK.book_id, BOOK.title, BOOK_AUTHOR.name as author_name, BOOK_PUBLISHER.name as publisher_name 
              FROM BOOK
              LEFT JOIN BOOK_AUTHOR ON BOOK.book_id = BOOK_AUTHOR.book_id
              LEFT JOIN BOOK_PUBLISHER ON BOOK.book_id = BOOK_PUBLISHER.book_id";
}

$result = mysqli_query($conn, $query);

$books = '{"books" : [';
$cnt = 0;

while($row = mysqli_fetch_array($result)){

  $cnt = $cnt +1;

  if($cnt!=1){
    $books = $books.',';
  }
  $books = $books.'{"book_id":"'.$row['book_id'].'","cover_image":"'.$row['cover_image_url'].'","book_title":"'.$row['title'].'","book_author":"'.$row['author_name'].'","book_publisher":"'.$row['publisher_name'].'"}';
}

$books= $books.']}';

echo $books;

mysqli_close($conn);

?>