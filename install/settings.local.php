<?php

/**
 * Assertions.
 */
assert_options(ASSERT_ACTIVE, TRUE);
\Drupal\Component\Assertion\Handle::register();

/**
 * Enable local development services.
 */
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/development.services.yml';

/**
 * Show all error messages, with backtrace information.
 */
$config['system.logging']['error_level'] = 'verbose';

/**
 * Disable CSS and JS aggregation.
 */
$config['system.performance']['css']['preprocess'] = FALSE;
$config['system.performance']['js']['preprocess']  = FALSE;

/**
 * Disable the render cache (this includes the page cache).
 */
$settings['cache']['bins']['render'] = 'cache.backend.null';

/**
 * Disable Internal Page Cache.
 */
$settings['cache']['bins']['page'] = 'cache.backend.null';

/**
 * Disable Dynamic Page Cache.
 */
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';

/**
 * Allow test modules and themes to be installed.
 */
$settings['extension_discovery_scan_tests'] = TRUE;

/**
 * Enable access to rebuild.php.
 */
$settings['rebuild_access'] = TRUE;

/**
 * Skip file system permissions hardening.
 */
$settings['skip_permissions_hardening'] = TRUE;

/**
 * Setting specific value for xdebug
 */
if (extension_loaded('xdebug')) {
  ini_set('xdebug.show_exception_trace', 0);
  ini_set('xdebug.collect_params', '?');
  ini_set('xdebug.max_nesting_level', 256);
}

/**
 * Development trusted host configuration.
 */
$settings['trusted_host_patterns'] = ['.*'];

/**
 * Update kint nested level
 */
if (file_exists(DRUPAL_ROOT . '/modules/contrib/devel/kint/kint/Kint.class.php')) {
  require_once DRUPAL_ROOT . '/modules/contrib/devel/kint/kint/Kint.class.php';
  Kint::$maxLevels = 4;
}
