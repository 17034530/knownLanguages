<?php
  include "db/db.php";
  include "cf/function.php";
  include "cf/header.php";
  $res['result'] = "DELETE Request Only";
  $res['check'] = false;

  if (checkMethod('DELETE')) {
    $jsonData = file_get_contents('php://input');
    $body = json_decode($jsonData, true);

    if(empty($body)){
      $res['result'] = "Invalid para";
      echo json_encode($res);
      exit();
    }

    $name = $body['name'];
    $token = $body['token'];
    if(checkToken($name,$token, $mysqli)){
      $logoutSQL = "DELETE FROM userSession WHERE (token = ?);";
      $stmt = $mysqli->prepare($logoutSQL);
      $stmt->bind_param("s", $token);
      $stmt->execute();
      if($stmt->affected_rows === 1){
        $res['result'] = "Successfully";
        $res['check'] = true;
      }else{
        $res['result'] = "Fail";
      }
    }else{
      $res['result'] = "Fail";
    }
    mysqli_close($mysqli);
  }
  echo json_encode($res);
?>