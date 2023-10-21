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

    try{
      $name = $body['name'];
      $password = $body['password'];
      $device = $body['device'] ? $body['device'] : "mac";
      if($name && $password){

        $checkUser = checkUserExist($name, $mysqli);
        
        if(is_array($checkUser)){ 
          if(password_verify($password,$checkUser['password'])){
            $token = genAccessToken($row, $device);
            $loginSQL = "INSERT INTO userSession (token, name, device) VALUES (?, ?, ?)";
            $stmt = $mysqli->prepare($loginSQL);
            $stmt->bind_param("sss", $token, $name, $device);
              
            if($stmt->execute()){
              $res['result']="Successfully";
              $res['check'] = true;
              $res['token']= $token;
            }else{
              $res['result']="Fail";
            }
            
          }else{
            $res['result'] = "Wrong name/password combination"; //wrong password
          }
        }else{
          $res['result'] = "Wrong name/password combination"; //invalid user
        }
      }else{
        $res['result'] = "Name/password is empty";
      }
      
    }catch (Exception $e) {
      $res['result'] = "try again later";
    }
    mysqli_close($mysqli);
  }
  echo json_encode($res);
?>