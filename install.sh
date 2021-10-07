#!/bin/bash

WEBROOT="/var/www/html"
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function prompt {
  ANSWER=""

  while [ -z "$ANSWER" ];
  do
    echo -ne "$1:\n ]> "
    read ANSWER
  done
}

function installComposer {
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
}

function installDependencies {
  apt-get update
  apt-get --allow-releaseinfo-change update
  apt-get update

  # Erstmal weg mit Apache xD
  apt-get purge -y apache2

  # Und rein...
  apt-get install -y curl
  apt-get install -y nginx
  apt-get install -y php7.3 php7.3-fpm php7.3-common php7.3-gd php7.3-imagick php7.3-mbstring php7.3-xml mariadb-server mariadb-client screen
  apt-get install -y redis

  if [ -L /usr/bin/php ]; then
    rm /usr/bin/php
  fi
  ln -s /usr/bin/php7.3 /usr/bin/php
}

function neosDirectory {
  echo -n "$WEBROOT/neos-$PROJECTSHORTID"
}

function createAdminPassword {
  cd $(neosDirectory)
  NEWPASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)
  echo $NEWPASSWORD > "admin-password.txt"
}

function administratorPassword {
  cd $(neosDirectory)
  [ ! -f "admin-password.txt" ] && createAdminPassword
  cat "admin-password.txt"
}

function resetMysqlRootPassword {
  ## Generate random password
  NEWPASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-12};echo;)

  ## Stop MySQL
  systemctl stop mysql
  ## Start MySQL without grant tables
  mysqld_safe --skip-grant-tables & 
  sleep 3
  ## Update root password
  mysql -e "update mysql.user set authentication_string=password('${NEWPASSWORD}'), plugin='mysql_native_password' where user = 'root'; flush privileges;"
  # Bye
  pkill -f mysql
  # Hi
  systemctl start mysql # Start MySQL Server regulary
  echo "----------------------"
  echo "$NEWPASSWORD"
  echo "$NEWPASSWORD" > ~/.mysql_pw-$(date +%s) # Save pw
}

function mysqlRootPassword {
  if [ -f ~/.mysql_pw-* ]; then
    cat ~/.mysql_pw-*
  else
    resetMysqlRootPassword &> /dev/null
    cat ~/.mysql_pw-*
  fi
}

function generateDatabase {
  PASSWORD=$(mysqlRootPassword)
  DIR=$(neosDirectory)

  if [ -f $DIR/mysql-data.txt ]; then
    return
  fi

  DBNAME="neos_$PROJECTSHORTID"
  echo "CREATE DATABASE $DBNAME" | mysql -uroot -p"$PASSWORD"
  echo "GRANT ALL ON $DBNAME.* to '$DBNAME'@'%' identified by '$PASSWORD'" | mysql -uroot -p"$PASSWORD"

  echo $DBNAME >> "$DIR/mysql-data.txt"
  echo $PASSWORD >> "$DIR/mysql-data.txt"
  echo $DBNAME >> "$DIR/mysql-data.txt"

  echo "#############"
  echo "DATABASE:"
  cat $DIR/mysql-data.txt
}

function installNeos {
  DIR=$(neosDirectory)
  if [ -d "$DIR" ]; then
    return
  fi
  cd $WEBROOT
  export COMPOSER_ALLOW_SUPERUSER=1;
  composer create-project neos/neos-base-distribution $(basename $(neosDirectory))

  if [ ! -f $DIR/Configuration/Settings.yaml ]; then
    cp $DIR/Configuration/Settings.yaml.example $DIR/Configuration/Settings.yaml
  fi
}

function kickStart {
  cd $(neosDirectory)
  echo "Dir: " $(pwd)
  echo "Removing neos/demo"
  export COMPOSER_ALLOW_SUPERUSER=1;
  composer remove neos/demo &> /dev/null
  echo "Pre-Clearing cache..."
  rm -rf Data/Temporary/*
  rm -rf Data/Persistent/Cache/*

  echo "Creating site package: $PROJECTFULLKEY"
  ./flow kickstart:site --packageKey "$PROJECTFULLKEY" --siteName "$PROJECTNAME"
  ./flow site:import "$PROJECTFULLKEY"
  echo "Clearing cache..."
  rm -rf Data/Temporary/*
  rm -rf Data/Persistent/Cache/*
}

function startInstaller {
  cd $(neosDirectory)
  pwd

  screen -XS "neos-dev" quit 2> /dev/null
  screen -dmS "neos-dev" ./flow server:run --host 0.0.0.0
  echo "Started dev-server"

  echo "Migrating database"
  ./flow doctrine:migrate

  createAdminPassword
  ADMINPW=$(cat admin-password.txt)

  cd $(neosDirectory)

  echo "Creating administrator"
  ./flow user:create --username "Administrator" --password "$ADMINPW" --firstName "Administrator" --lastName "Administrator" --role "Neos.Neos:Administrator"

  screen -XS "neos-dev" quit 2> /dev/null
  screen -dmS "neos-dev" ./flow server:run --host 0.0.0.0
  echo "Started dev-server"
}

function yamlDatabaseConfig {
  cd $SCRIPTDIR
  apt-get install -y python python-pip
  pip install pyyaml
  python ./files/database.py $(neosDirectory)
}

function saveConfig {
  cd $(neosDirectory)
  echo $PROJECTFULLKEY > ".project-namespace"
}

###############################
## Program start
###############################

CONFIGDONE=""

while [ -z "$CONFIGDONE" ] || [ "$CONFIGDONE" != "y" ]; do
  prompt "Project name"
  PROJECTNAME="$ANSWER"
  prompt "Vendor (Agency name)"
  PROJECTVENDOR="$ANSWER"
  prompt "Project-Key (Short proj. name)"
  PROJECTKEY="$ANSWER"
  PROJECTFULLKEY="$PROJECTVENDOR.$PROJECTKEY"
  PROJECTID=$(echo "$PROJECTFULLKEY" | tr '[:upper:]' '[:lower:]' | tr '.' '-')
  PROJECTSHORTID=$(echo "$PROJECTKEY" | tr '[:upper:]' '[:lower:]')
  DIR=$(neosDirectory)

  echo "#######"
  echo -e "Configuration"
  echo -e "\tKey: $PROJECTFULLKEY"
  echo -e "\tFull-Id: $PROJECTID"
  echo -e "\tShort-Id: $PROJECTSHORTID"
  echo -e "\tDirectory: $DIR"
  echo -e "\tBasename:" $(basename $(neosDirectory))
  echo "#######"

  prompt "Continue? (Type y)"
  CONFIGDONE="$ANSWER"
done

echo 

echo "Installing dependencies..."
installDependencies > /dev/null

echo "Installing composer..."
installComposer > /dev/null

echo "Installing neos"
installNeos

echo "Preparing database"
generateDatabase

echo "Configuring database for neos"
yamlDatabaseConfig

echo "Starting installer"
startInstaller

echo "Alright, kickstarting!"
kickStart

echo "Neos should now be ready"
echo "Username: Administrator"
echo "Password:" $(administratorPassword)

cd $(neosDirectory)
screen -XS "neos-dev" quit 2> /dev/null
screen -dmS "neos-dev" ./flow server:run --host 0.0.0.0
echo "Started dev-server"
