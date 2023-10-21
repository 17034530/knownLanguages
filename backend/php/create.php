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

    if(!regexPassword($body['password'])){
      $res['result'] = "Invalid Password format";
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
    $email = $body['email'];
    $dob = $body['dob'];
    $gender = $body['gender'];

    $hashPW = genHashPW($password);

    $timezone = new DateTimeZone('Asia/Singapore'); // Adjust to your specific time zone
    $date = new DateTime('now', $timezone);
    $doc = $date->format('Y-m-d H:i:s');
    if($dob == ""){
      $dob = NULL;
    }
    if($gender == ""){
      $gender = NULL;
    }

    $query = "INSERT INTO users (name, password, email, DOB, gender, dateOfCreation) VALUES (?, ?, ?, ?, ?, ?)";
    $stmt = $mysqli->prepare($query);
    $stmt->bind_param("ssssss", $name, $hashPW, $email, $dob, $gender, $doc); 

    try {
      if($stmt->execute()){
        $res['result'] = "Added";
        $res['check'] = true;
      }
    }catch (Exception $e) {
      $res['result'] = "try again later";
    }
    mysqli_close($mysqli);
  }
  echo json_encode($res);
?>