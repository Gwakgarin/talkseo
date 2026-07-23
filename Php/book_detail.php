<?php
include 'db.php';

$book_id = isset($_POST['book_id']) ? $_POST['book_id'] : '';

$query = "
SELECT
    BOOK.book_id,
    BOOK.title,
    BOOK.cover_image_url,
    BOOK.summary,
    BOOK.total_pages,
    BOOK.isbn,
    BOOK_AUTHOR.name AS author_name,
    BOOK_PUBLISHER.name AS publisher_name
FROM BOOK
LEFT JOIN BOOK_AUTHOR ON BOOK.book_id = BOOK_AUTHOR.book_id
LEFT JOIN BOOK_PUBLISHER ON BOOK.book_id = BOOK_PUBLISHER.book_id
WHERE BOOK.book_id = '$book_id'
";

$result = mysqli_query($conn, $query);

$book = '{';

if ($row = mysqli_fetch_array($result)) {

   $book .= '"book_id":"'.$row['book_id'].'",';
   $book .= '"title":"'.$row['title'].'",';
   $book .= '"cover_image_url":"'.$row['cover_image_url'].'",';
   $book .= '"summary":"'.$row['summary'].'",';
   $book .= '"total_pages":"'.$row['total_pages'].'",';
   $book .= '"isbn":"'.$row['isbn'].'",';
   $book .= '"author":"'.$row['author_name'].'",';
   $book .= '"publisher":"'.$row['publisher_name'].'"';
}

$book .= '}';

echo $book;

mysqli_close($conn);
?>
