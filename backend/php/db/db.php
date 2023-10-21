<?php
  include 'cf/loadenv.php';

  $host = getenv('HOST');
  $port = getenv('DBPORT');
  $db   = getenv('DATABASE');
  $user = getenv('DBUSER');
  $pass = getenv('PASSWORD');

  $mysqli = mysqli_connect($host, $user, $pass, $db);
  if ($mysqli->connect_error) {
    // die("Connection failed: " . $mysqli->connect_error);
    $res['result'] = "Try again later";
    $res['check'] = false;
    echo json_encode($res);
  }

?>