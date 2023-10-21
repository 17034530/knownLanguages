<?php
  include "db/db.php";
  include "cf/function.php";
  include "cf/header.php";
  $res['result'] = "PATCH Request Only";
  $res['check'] = false;


  if (checkMethod('PATCH')) {
    $jsonData = file_get_contents('php://input');
    $body = json_decode($jsonData, true);

    if(empty($body)){
      $res['result'] = "Invalid para";
      echo json_encode($res);
      exit();
    }

    if($body['name'] === ""){
      $res['result'] = "Name is required";
      echo json_encode($res);
      exit();
    }

    if($body['password'] === ""){
      $res['result'] = "Password is required";
      echo json_encode($res);
      exit();
    }

    if($body['email'] === ""){
      $res['result'] = "Email is required";
      echo json_encode($res);
      exit();
    }

    if(!regexEmail($body['email'])){
      $res['result'] = "Invalid Email format";
      echo json_encode($res);
      exit();
    }

    $name = trim($body['name']);
    $password = $body['password'];
    $newPassword = $body['newPassword'];
    $email = $body['email'];
    $dob = $body['dob'] === "" ? NULL : $body['dob'];
    $gender = $body['gender'] === "" ? NULL : $body['gender'];
    $token = $body['token'];

    $timezone = new DateTimeZone('Asia/Singapore'); // Adjust to your specific time zone
    $date = new DateTime('now', $timezone);
    $doc = $date->format('Y-m-d H:i:s');
    if($dob == ""){
      $dob = NULL;
    }
    if($gender == ""){
      $gender = NULL;
    }

    if(checkToken($name,$token, $mysqli)){
      $checkUser = checkUserExist($name,$mysqli);
      if(is_array($checkUser)){
        if(password_verify($password,$checkUser['password'])){
          if($newPassword && regexPassword($newPassword)){
            $hashPW = genHashPW($password);
            $result = updateAll($hashPW, $email, $dob, $gender, $name, $mysqli);
            $res['result'] = $result[0];
            $res['check'] = $result[1];
          }else if($newPassword){ //new password wrong format
            $res['result'] = "Invalid new password format";
          }else{
            $result = updateEmail($email, $dob, $gender, $name, $mysqli);
            $res['result'] = $result[0];
            $res['check'] = $result[1];
          }
        }else{
          $res['result'] = "Wrong current password";
        }
      }else{
        $res['result'] = "Wrong username/password combination";
      }
    }else{
      $res['result'] = "FAIL"; //jwt token fail
    }
    

    mysqli_close($mysqli);
  }
  echo json_encode($res);
?>