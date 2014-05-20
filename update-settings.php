<?php


  // Get parameters from shell script
  $user = $argv[1];
  $project_dir = $argv[2];
  $db_user = $argv[3];
  $db_pass = $argv[4];
  $db_name = $argv[5];

  $default_settings = 'sites/default/default.settings.php';
  define('DRUPAL_ROOT', '/home/' . $user . '/public_html/' . $project_dir);
  $settings_file = 'sites/default/settings.php';

  $settings = array(
  'databases' => array(
    'value' => array(
      'default' => array(
        'default' => array(
          'database' => $db_name,
          'username' => $db_user,
          'password' => $db_pass,
          'host' => 'localhost',
          'port' => '',
          'driver' => 'mysql',
          'prefix' => '',
          )
        )
      )
    )
  );

  // Build list of setting names and insert the values into the global namespace.
  $keys = array();
  foreach ($settings as $setting => $data) {
    $GLOBALS[$setting] = $data['value'];
    $keys[] = $setting;
  }


  $buffer = NULL;
  $first = TRUE;
  if ($fp = fopen(DRUPAL_ROOT . '/' . $default_settings, 'r')) {
    // Step line by line through settings.php.
    while (!feof($fp)) {
      $line = fgets($fp);
      if ($first && substr($line, 0, 5) != '<?php') {
        $buffer = "<?php\n\n";
      }
      $first = FALSE;
      // Check for constants.
      if (substr($line, 0, 7) == 'define(') {
        preg_match('/define\(\s*[\'"]([A-Z_-]+)[\'"]\s*,(.*?)\);/', $line, $variable);
        if (in_array($variable[1], $keys)) {
          $setting = $settings[$variable[1]];
          $buffer .= str_replace($variable[2], " '" . $setting['value'] . "'", $line);
          unset($settings[$variable[1]]);
          unset($settings[$variable[2]]);
        }
        else {
          $buffer .= $line;
        }
      }
      // Check for variables.
      elseif (substr($line, 0, 1) == '$') {
        preg_match('/\$([^ ]*) /', $line, $variable);
        if (in_array($variable[1], $keys)) {
          // Write new value to settings.php in the following format:
          //    $'setting' = 'value'; // 'comment'
          $setting = $settings[$variable[1]];
          $buffer .= '$' . $variable[1] . " = " . var_export($setting['value'], TRUE) . ";" . (!empty($setting['comment']) ? ' // ' . $setting['comment'] . "\n" : "\n");
          unset($settings[$variable[1]]);
        }
        else {
          $buffer .= $line;
        }
      }
      else {
        $buffer .= $line;
      }
    }
    fclose($fp);

    // Add required settings that were missing from settings.php.
    foreach ($settings as $setting => $data) {
      if ($data['required']) {
        $buffer .= "\$$setting = " . var_export($data['value'], TRUE) . ";\n";
      }
    }

    $fp = fopen(DRUPAL_ROOT . '/' . $settings_file, 'w');
    if ($fp && fwrite($fp, $buffer) === FALSE) {
      throw new Exception(st('Failed to modify %settings. Verify the file permissions.', array('%settings' => $settings_file)));
    }
  }
  else {
    throw new Exception(st('Failed to open %settings. Verify the file permissions.', array('%settings' => $default_settings)));
  }

