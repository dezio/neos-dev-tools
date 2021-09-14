#!/bin/bash
DIR="$1"
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function installNode {
  echo "Installing nodejs"

  if [ ! -x node ]; then
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -  > /dev/null
    apt-get install -y nodejs > /dev/null
  fi
  echo "Version:" $(node --version)
}

function initNpm {
  cd $DIR
  if [ ! -f $DIR/package.json ]; then
    npm init -y
  fi

  # Tailwind
  echo "Installing tailwind..."
  npm install -D tailwindcss@latest @tailwindcss/typography postcss@latest postcss-import@latest autoprefixer@latest &> /dev/null

  # Typescript
  echo "Installing typescript..."
  npm install -D typescript@latest &> /dev/null

  # Mix
  echo "Installing laravel-mix..."
  npm install -D laravel-mix@latest cross-env@latest &> /dev/null
  npm install -D ts-loader --save-dev --legacy-peer-deps &> /dev/null
}

function createStructure {
  echo "Creating structure..."
  mkdir -p $DIR/Resources/Sources &> /dev/null
  mkdir -p $DIR/Resources/Sources/Style &> /dev/null
  mkdir -p $DIR/Resources/Sources/Style/Components &> /dev/null
  mkdir -p $DIR/Resources/Sources/Script &> /dev/null

  touch $DIR/Resources/Sources/Script/App.ts &> /dev/null
  touch $DIR/Resources/Sources/Style/App.css &> /dev/null
  touch $DIR/Resources/Sources/Style/Base.css &> /dev/null

  cp $SCRIPTDIR/files/{postcss.config.js,tsconfig.json,webpack.mix.js,tailwind.config.js} $DIR
  cp $SCRIPTDIR/files/App.css $DIR/Resources/Sources/Style/App.css

  npx npm-add-script -k "watch" -v "mix watch" --force
  npx npm-add-script -k "build" -v "cross-env NODE_ENV=production mix build" --force

  echo "Structure: "
  find $DIR/Resources/Sources
}

function compileOnce {
    cd $DIR
    echo "Compiling once..."
    npm run-script build &> /dev/null
}

installNode
initNpm
createStructure
compileOnce