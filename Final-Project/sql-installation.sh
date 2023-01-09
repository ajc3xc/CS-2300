#!/bin/bash

#Commands to install mysql server and mysql shell
#These are the only two dependencies
sudo apt-get update;
sudo apt install mariadb-server mariadb-client -y;
mysql -e "UPDATE mysql.user SET Password = PASSWORD('CHANGEME') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
#add new user
mysql -e "CREATE USER 'exampleuser'@'localhost' IDENTIFIED BY 'password'"
#give priviliges to user
mysql -e "GRANT ALL PRIVILEGES ON * TO "exampleuser'@'localhost' IDENTIFIED BY 'password'"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"
mysql -u exampleuser -ppassword HydroFarm