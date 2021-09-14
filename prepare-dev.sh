#!/bin/bash
DIR="$1"

function installNode {
  curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
  apt-get install -y nodejs npm
}

function initNpm {
  cd $DIR
  yes | npm init
  # Tailwind
  npm install -D tailwindcss@latest postcss@latest autoprefixer@latest

  # Typescript
  npm install -D typescript@latest

  # Mix
  npm install -D laravel-mix@latest
}

function createStructure {
  mkdir -p $DIR/Resources/Sources
  mkdir -p $DIR/Resources/Sources/Style
  mkdir -p $DIR/Resources/Sources/Script
}

installNode
initNpm
createStructure