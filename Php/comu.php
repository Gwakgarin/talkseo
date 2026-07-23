<?php
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

$query="SELECT USERS.id, USERS.nickname, USERS.profile_image_url, 
COMMUNITY_POST.content, COMMUNITY_POST.update_date, COMMUNITY_POST.post_id, COMMUNITY_POST.title, COMMUNITY_POST.insert_date,
(SELECT COUNT(POST_LIKE.post_id) from POST_LIKE where POST_LIKE.post_id = COMMUNITY_POST.post_id) as like_count,
(SELECT COUNT(POST_COMMENT.post_id) from POST_COMMENT where POST_COMMENT.post_id = COMMUNITY_POST.post_id) as comment_count
from COMMUNITY_POST
left join USERS on USERS.user_id = COMMUNITY_POST.user_id";
$result=mysqli_query($conn, $query);

$COMMUNITY_POST='{"COMMUNITY_POST":[';
$cnt=0;
while($row=mysqli_fetch_array($result)) {
    $cnt=$cnt+1;

    if($cnt!=1) {
        $COMMUNITY_POST=$COMMUNITY_POST.',';
    }

    $COMMUNITY_POST = $COMMUNITY_POST.'{
    "user_id": "'.$row['id'].'",
    "nickname": "'.$row['nickname'].'",
    "profile_image_url": "'.$row['profile_image_url'].'",
    "content": "'.$row['content'].'",
    "update_date": "'.$row['update_date'].'",
    "post_id": '.$row['post_id'].',
    "title": "'.$row['title'].'",
    "insert_date": "'.$row['insert_date'].'",
    "like_count": '.$row['like_count'].',
    "comment_count": '.$row['comment_count'].'
    }';
   
}
    $COMMUNITY_POST=$COMMUNITY_POST.']}';

    echo $COMMUNITY_POST;

    mysqli_close($conn);
?>