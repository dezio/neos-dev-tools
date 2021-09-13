#!/bin/bash

WEBROOT="/var/www/html"
SCRIPTDIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

function prompt {
  ANSWER=""

  while [ -z "$ANSWER" ];
  do
    echo -n "$1 > "
    read ANSWER
  done
}

function installComposer {
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
}

function installDependencies {
  apt-get install -y curl
  apt-get install -y nginx
  apt-get install -y php7.3 php7.3-fpm php7.3-common php7.3-gd php7.3-imagick php7.3-mbstring mariadb-server mariadb-client screen
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
}

function startInstaller {
  cd $(neosDirectory)
  pwd

  echo "Migrating database"
  ./flow doctrine:migrate
  ADMINPW=$(cat admin-password.txt)

  echo "Creating administrator"
  ./flow user:create --username "Administrator" --password "$ADMINPW" --firstName "Administrator" --lastName "-" --role "Neos.Neos:Administrator"

  screen -XS "neos-dev" quit 2> /dev/null
  screen -dmS "neos-dev" ./flow server:run --host 0.0.0.0
  echo "Started dev-server"
}

function yamlDatabaseConfig {
  cd $SCRIPTDIR
  apt-get install python python-pip
  pip install pyyaml
  python ./files/database.py $(neosDirectory)
}

function kickStart {
  cd $(neosDirectory)
  echo "Dir: " $(pwd)
  echo "Removing neos/demo"
  export COMPOSER_ALLOW_SUPERUSER=1;
  composer remove neos/demo &> /dev/null
  echo "Creating site package: $PROJECTFULLKEY"
  ./flow kickstart:site --packageKey "$PROJECTFULLKEY" --siteName "$PROJECTNAME"
  echo "Clearing cache..."
  rm -rf Data/Temporary/*
  rm -rf Data/Persistent/Cache/*
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
  echo "Configuration: "
  echo "Key: $PROJECTFULLKEY"
  echo "Full-Id: $PROJECTID"
  echo "Short-Id: $PROJECTSHORTID"
  echo "Directory: $DIR"
  echo "Basename: " $(basename $(neosDirectory))
  echo "#######"

  prompt "Continue? (Type y)"
  CONFIGDONE="$ANSWER"
done

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

echo "Once the installer is done, type done here: "

DONE=""
while [ "$DONE" != "done" ]; do
  read DONE
done

echo "Alright, kickstarting!"
kickStart

echo "Neos should now be ready"