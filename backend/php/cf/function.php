<?php 

  function regexPassword($password){
    $pwreg = '/^(?=.*\d)(?=.*[a-z]).{8,10}$/';
    return preg_match($pwreg, $password);
  }

  function regexEmail($email){
    $emailreg = '/^[a-zA-Z0-9.!#$%&\'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/';
    return preg_match($emailreg, $email);
  }

  function checkMethod($method){
    return $_SERVER['REQUEST_METHOD'] === $method;
  }

  function genAccessToken($userInfo, $device){
    $header = json_encode(['alg' => 'HS256', 'typ' => 'JWT']); // JWT header
    $payload = json_encode(['username' => $userInfo['name'], 'device' => $device, 'iat' => time()]); // JWT payload
    // Base64 encode the header and payload
    $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
    $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
    
    $AccessKey = getenv('ACCESSKEY');

    $signature = hash_hmac('sha256', $base64UrlHeader . '.' . $base64UrlPayload, $AccessKey, true);

    // Base64 encode the signature
    $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

    // Combine the header, payload, and signature to create the JWT token
    $jwt = $base64UrlHeader . '.' . $base64UrlPayload . '.' . $base64UrlSignature;

    return $jwt;
  }

  function checkToken($name, $token, $mysqli){
    $checkSessionSQL = "SELECT * FROM userSession WHERE name =? AND token = ?;";
    $stmt = $mysqli->prepare($checkSessionSQL);
    $stmt->bind_param("ss", $name, $token);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->num_rows == 1;    
  }

  function checkUserExist($name, $mysqli){
    $checkUserExistSQL = "SELECT * FROM users WHERE name = ?";
    $stmt = $mysqli->prepare($checkUserExistSQL);
    $stmt->bind_param("s", $name);
    $stmt->execute();
    $result = $stmt->get_result();
    if($result->num_rows == 1){
      return $result->fetch_assoc();
    }
    return "";
  }

  function updateAll($password, $email, $dob, $gender, $name, $mysqli) {
    $updateAllSQL = "UPDATE users SET password = ?, email = ?, dob = ?, gender = ? WHERE (name = ?);";
    $stmt = $mysqli->prepare($updateAllSQL);
    $stmt->bind_param("sssss", $password, $email, $dob, $gender, $name);
    if($stmt->execute()){
      return ["Profile updated", true];
    }
    return ["Fail", false];
  }

  function updateEmail($email, $dob, $gender, $name, $mysqli){
    $updateEmailSQL = "UPDATE users SET email = ?, dob = ?, gender = ? WHERE (name = ?);";
    $stmt = $mysqli->prepare($updateEmailSQL);
    $stmt->bind_param("ssss", $email, $dob, $gender, $name);
    if($stmt->execute()){
      return ["Profile updated", true];
    }
    return ["Fail", false];
  }

  function genHashPW($password){
    $options = [
      'cost' => 10, // Number of salt rounds
    ];
    $hashPW = password_hash($password, PASSWORD_BCRYPT, $options);
    return str_replace("$2y$", "$2a$", $hashPW); //to allow node to check
  }
?>