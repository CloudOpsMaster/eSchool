#!/bin/bash

#ENVIRONMENT
DATASOURCE_USERNAME=eschool
DATASOURCE_PASSWORD=b1dnijpesvseshesre
MYSQL_ROOT_PASSWORD=legme876FCTFEfg1


#Updating OS
sudo apt update && sudo apt upgrade -y

#Installing docker
sudo apt install docker.io -y

#Installing Java
sudo apt install openjdk-8-jdk-headless maven -y
sudo update-java-alternatives -s java-1.8.0-openjdk-amd64

cd /home/ubuntu

#Clonning eschool repository
git clone https://github.com/Maks0123/eSchool.git

#Set current year in ScheduleControllerIntegrationTest
sed -i 's/2019/'`date +%Y`'/g' ./eSchool/src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java

#Set application default login and pass to admin:admin
sed -i 's/administrator/admin/g' ./eSchool/src/main/resources/application.properties
sed -i 's/OFKFvBCMnyZ012NSNzzFmw==/admin/g' ./eSchool/src/main/resources/application.properties

#Set application database credentials
sed -i 's/DATASOURCE_USERNAME:root/DATASOURCE_USERNAME:'${DATASOURCE_USERNAME}'/g' ./eSchool/src/main/resources/application.properties
sed -i 's/DATASOURCE_PASSWORD:root/DATASOURCE_PASSWORD:'${DATASOURCE_PASSWORD}'/g' ./eSchool/src/main/resources/application.properties


#Building eschool application
cd ./eSchool
mvn clean
mvn package
cd ..

#Forming env file for mysql instance
echo "MYSQL_USER=${DATASOURCE_USERNAME}" > env
echo "MYSQL_PASSWORD=${DATASOURCE_PASSWORD}" >> env
echo "MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}" >> env
echo "MYSQL_DATABASE=eschool" >> env

#Starting mysql server in docker container
sudo docker run --env-file ./env --name mysql -p 127.0.0.1:3306:3306 -v /home/ubuntu/mysql:/var/lib/mysql -d mysql:5.7 --innodb_use_native_aio=0 --character-set-server=utf8 --collation-server=utf8_unicode_ci 

#Waiting for mysql start 
sleep 10

#Starting eschool application
nohup java -jar ./eSchool/target/eschool.jar &