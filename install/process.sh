#!/bin/bash

NOTICE='\e[1;37;46m%s\e[0m\n'
SUCCESS='\e[1;37;42m%s\e[0m\n'
ERROR='\e[1;37;41m%s\e[0m\n'

if [[ -z $(ls -A ./vendor 2>/dev/null) ]]; then
  echo -n "vendor directory is not found! "
  printf "${NOTICE}" "Try to launch first command composer install"
  exit 1
fi

if [[ ! -f ./vendor/bin/drush ]]; then
  echo -n "vendor/bin/drush is not found! "
  printf "${NOTICE}" "Try to launch command composer req drush/drush"
  exit 1
fi

echo -n "Drupal version core: "
echo "$(./vendor/bin/drush st --field=drupal-version)"

echo -n "Drush version: "
echo "$(./vendor/bin/drush st --field=drush-version)"

echo -n "Connected to database... "
if [[ $(./vendor/bin/drush st --field=db-status) = Connected ]]; then
  printf "${SUCCESS}" "[success]"

  echo "Import configuration file"
  ./vendor/bin/drush cim -y

  echo "Update database"
  ./vendor/bin/drush updb -y

  echo "Update entity schema"
  ./vendor/bin/drush devel-entity-updates

  echo "Rebuild permission"
  ./vendor/bin/drush php-eval 'node_access_rebuild();'

  echo "Update locale"
  ./vendor/bin/drush locale:update

  echo "Clear cache"
  ./vendor/bin/drush cr
else
  printf "${ERROR}" "[error]"
  printf "${NOTICE}" "Try to launch first command drush si standard --account-name=<NAME> --account-pass=<PASS> --locale=en -y"
fi
