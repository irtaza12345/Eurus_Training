#!/bin/bash

print_green() {
  echo -e "\e[32m$1\e[0m"
}
print_red() {
  echo -e "\e[31m$1\e[0m"
}

# Check for root
if [[ $EUID -ne 0 ]]; then
  print_red "This script must be run as root."
  exit 1
fi

# Load environment variables
if [[ -f "./environment_variable" ]]; then
  source ./environment_variable
else
  print_red "Environment_variable file not found."
  exit 1
fi

# Validate required environment variables
if [[ -z "$DB_ROOT_PASSWORD" || -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_USER_PASSWORD" ]]; then
  print_red "Missing environment_variables.Some values missing."
  exit 1
fi

print_green "Updating package index and upgrading installed packages..."
apt-get update && apt-get upgrade -y

print_green "Installing prerequisites..."
apt-get install -y software-properties-common curl
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install -y php7.4 php7.4-mysql php7.4-curl php7.4-gd php7.4-mbstring php7.4-xml php7.4-zip php7.4-xmlrpc

print_green "Installing MySQL server..."
DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

print_green "Creating MySQL database and user..."
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

print_green "Installing Apache web server..."
apt-get install -y apache2
a2enmod rewrite
systemctl restart apache2

print_green "Downloading and extracting WordPress..."
cd /tmp
curl -LO https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz -C /var/www/html/
chown -R www-data:www-data /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress
rm /tmp/latest.tar.gz

print_green "WordPress installation is complete."
