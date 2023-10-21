<?php
  include "db/db.php";
  include "cf/function.php";
  include "cf/header.php";
  $res['result'] = "POST Request Only";
  $res['check'] = false;

  if (checkMethod('POST')) {
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
      $checkUser = checkUserExist($name, $mysqli);
      if(is_array($checkUser)){
        $dob = strtotime($checkUser['DOB']); 
        $checkUser['DOB'] =date('m/d/Y', $dob) === '01/01/1970' ? null : date('m/d/Y', $dob);
        $res['check'] = true;
      }
      $res['result'] = $checkUser;
    }else{
      $res['result'] = "Fail"; //jwt token fail
    }
    mysqli_close($mysqli);
  }
  echo json_encode($res);
?>