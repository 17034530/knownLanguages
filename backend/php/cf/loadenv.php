<?php 
  $envFilePath = 'config/config.env'; //change to base.env or create a config.env in config
  if (file_exists($envFilePath)) {
    $envContent = file_get_contents($envFilePath);
    $lines = explode(PHP_EOL, $envContent);
    foreach ($lines as $line) {
      $parts = explode('=', $line, 2);
      if (count($parts) === 2) {
        list($key, $value) = $parts;
        putenv("{$key}={$value}");//to let getenv() work
        // $_ENV[trim($key)] = trim($value);//to let $_ENV[] work
      }
    }
  }
?>