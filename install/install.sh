#!/bin/sh
set -e

delete_settings(){
  if [ -f web/sites/default/settings.php ]; then
    echo "Delete settings.php"
    rm -f web/sites/default/settings.php
  fi
}

configuration(){
  echo "Copy all configuration files"
  cp web/sites/default/default.services.yml web/sites/default/services.yml
  cp web/sites/development.services.yml web/sites/default/development.services.yml
  cp install/development.twig.services.yml web/sites/default/development.twig.services.yml
  cp install/settings.local.php web/sites/default/settings.local.php
  cp install/settings.php web/sites/default/settings.php
}

permission(){
  echo "Change permission for directory web/sites"
  find web/sites/ -maxdepth 2 -type f -exec chmod 664 "{}" \;
  find web/sites/ -maxdepth 2 -type d -exec chmod 775 "{}" \;
  find web/sites/default/ -maxdepth 1 -type f \( -iname "*.*" ! -iname "default*" \) -exec chmod 444 "{}" \;
  find web/sites/default/ -maxdepth 0 -type d -exec chmod 755 "{}" \;
  find web/sites/ -maxdepth 2 -type d -exec chgrp $(id -g) "{}" \;
}

create_env(){
  if [ -f .env ]; then
    echo "Le fichier .env est déjà créé!"
  else
    DRUPAL_HASH=`vendor/bin/drush eval "echo Drupal\Component\Utility\Crypt::randomBytesBase64(55)"`

    echo "Création du fichier .env"
    read -r -p 'DB_DATABASE: ' DB_DATABASE
    read -r -p 'DB_HOSTNAME: ' DB_HOSTNAME
    read -r -p 'DB_USER: ' DB_USER
    read -r -p -s 'DB_PASSWORD: ' DB_PASSWORD
    read -r -p 'DB_PREFIX (null): ' DB_PREFIX
    read -r -p 'DB_PORT (3306): ' DB_PORT
    read -r -p 'DRUPAL_SYNC_DIR (../config/sync): ' DRUPAL_SYNC_DIR
    read -r -p 'DRUPAL_BATCH_SIZE (50): ' DRUPAL_BATCH_SIZE
    read -r -p 'DRUPAL_PUBLIC_PATH (sites/default/files): ' DRUPAL_PUBLIC_PATH
    read -r -p 'DRUPAL_PRIVATE_PATH (sites/default/private): ' DRUPAL_PRIVATE_PATH

    cat > .env <<EOF
DB_DATABASE=$DB_DATABASE
DB_HOSTNAME=$DB_HOSTNAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_PREFIX=${DB_PREFIX:-}
DB_PORT=${DB_PORT:-3306}

DRUPAL_HASH=$DRUPAL_HASH
DRUPAL_SYNC_DIR=${DRUPAL_SYNC_DIR:-../config/sync}

DRUPAL_BATCH_SIZE=${DRUPAL_BATCH_SIZE:-50}
DRUPAL_PUBLIC_PATH=${DRUPAL_PUBLIC_PATH:-sites/default/files}
DRUPAL_PRIVATE_PATH=${DRUPAL_PRIVATE_PATH:-sites/default/private}
EOF

    echo "Site configuré avec succès !"
  fi
}

intallation(){
  echo "Installation du Drupal"

  read -r -p 'Choisissez votre profil (standard, minimal): ' PROFILE
  read -r -p 'Nom du compte admin: ' NAME
  read -r -p 'Mot de passe du compte admin: ' PASS
  read -r -p 'Langue du site (en, fr, ..): ' LOCALE

  `vendor/bin/drush si $PROFILE --account-name=$NAME --account-pass=$PASS --locale=$LOCALE -y`
  `vendor/bin/drush cex -y`
}

delete_settings
configuration
permission
create_env
