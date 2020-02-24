# Drupal Docker

A Docker installer for runtime Drupal inspired by symfony-docker from dunglas.

## Getting started

1. Run `make build` to build all image and run docker
2. Open `http://localhost` to start

## Use environment to change website configuration

Use environment variable `DRUPAL_VERSION` to select specific Drupal version :
`DRUPAL_VERSION=8.* docker-compose up --build`

Use environment variable `STABILITY` to select specific Drupal version :
`DRUPAL_VERSION=8.* STABILITY=dev docker-compose up --build`