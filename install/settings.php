<?php

// @codingStandardsIgnoreFile

/**
 * @file
 * Drupal site-specific configuration file.
 */

/**
 * Location of the site configuration files.
 */
$config_directories['sync'] = getenv('DRUPAL_SYNC_DIR') ? getenv('DRUPAL_SYNC_DIR') : '';

/**
 * Salt for one-time login links, cancel links, form tokens, etc.
 */
$settings['hash_salt'] = getenv('DRUPAL_HASH');

/**
 * Access control for update.php script.
 */
$settings['update_free_access'] = FALSE;

/**
 * Load services definition file.
 */
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';

/**
 * The active installation profile.
 */
$settings['install_profile'] = 'standard';

/**
 * Directories
 */
if (getenv('DRUPAL_PUBLIC_PATH')) {
  $settings['file_public_path'] = getenv('DRUPAL_PUBLIC_PATH');
}
if (getenv('DRUPAL_PRIVATE_PATH')) {
  $settings['file_private_path'] = getenv('DRUPAL_PRIVATE_PATH');
}

/**
 * The default list of directories that will be ignored by Drupal's file API.
 */
$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];

/**
 * The default number of entities to update in a batch process.
 */
$settings['entity_update_batch_size'] = getenv('DRUPAL_BATCH_SIZE') ? getenv('DRUPAL_BATCH_SIZE') : 50;

/**
 * Database settings
 */
$databases['default']['default'] = [
  'database'  => getenv('DB_DATABASE'),
  'username'  => getenv('DB_USER'),
  'password'  => getenv('DB_PASSWORD'),
  'host'      => getenv('DB_HOSTNAME'),
  'prefix'    => getenv('DB_PREFIX') ? getenv('DB_PREFIX') : '',
  'port'      => getenv('DB_PORT') ? getenv('DB_PORT') : '',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver'    => 'mysql',
];

/**
 * Development settings
 */
if ('dev' === getenv('APP_ENV')) {
  if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
    include $app_root . '/' . $site_path . '/settings.local.php';
  }

  if ('TRUE' == getenv('TWIG_DEBUG') || '1' == getenv('TWIG_DEBUG')) {
    $settings['container_yamls'][] = $app_root . '/' . $site_path . '/development.twig.services.yml';
  }
}
