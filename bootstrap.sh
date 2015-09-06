#!/usr/bin/env bash

# ----------------------------------------
# Provisioning for a CSD Class.
# Kiet Tran 2015
# ----------------------------------------

# Installing tools ...
if ! [ -f /usr/bin/unzip ]; then
  echo "Installing tools ...";
  sudo yum install -y unzip;
  sudo yum install -y git;
  cd /opt
  sudo mkdir selenium-server
  sudo cp /vagrant/bin/selenium-server-standalone-2.45.0.jar /opt/selenium-server/.
else 
  echo "Skipping Installing tools ...";
fi


## Installing JDK 8 from ORACLE
if ! [ -d /opt/jdk ]; then
  echo "Installing JDK 1.8, Maven 3.3.3";
  cd /opt;
  # sudo wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz";
  # http://tecadmin.net/install-java-8-on-centos-rhel-and-fedora/
  sudo cp /vagrant/bin/jdk-8u45-linux-x64.tar.gz .
  sudo tar xvf jdk-8u45-linux-x64.tar.gz;
  sudo cd /opt/jdk1.8.0_45;
  sudo alternatives --install /usr/bin/java java /opt/jdk1.8.0_45/bin/java 2;
  sudo alternatives --config java;
  sudo alternatives --install /usr/bin/jar jar /opt/jdk1.8.0_45/bin/jar 2;
  sudo alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_45/bin/javac 2;
  sudo alternatives --set jar /opt/jdk1.8.0_45/bin/jar;
  sudo alternatives --set javac /opt/jdk1.8.0_45/bin/javac;
  sudo mv /etc/environment /etc/environment_orig;
  sudo cp /vagrant/environment_to_etc /etc/environment;
  sudo rm jdk-8u45-linux-x64.tar.gz;

  # Instaling Maven 3.3.3
  cd /opt;
  cp /vagrant/bin/apache-maven-3.3.3-bin.tar.gz .;
  sudo tar xvf apache-maven-3.3.3-bin.tar.gz;
  sudo mv apache-maven-3.3.3 maven;
  sudo alternatives --install /usr/bin/mvn mvn /opt/maven/bin/mvn 1;
  sudo rm apache-maven-3.3.3-bin.tar.gz;
else
  echo "Skipping JDK 1.8, Maven 3.3.3";
fi

export JAVA_HOME=/opt/jdk1.8.0_45;
export MAVEN_HOME=/opt/maven;

## Install Tomee 1.7.2:
if ! [ -d /opt/tomee ]; then
  echo "Installing TOMEE 1.7.2 ...";
  cd /opt;
  cp /vagrant/bin/apache-tomee-1.7.2-plume.tar.gz .
  sudo tar xzf apache-tomee-1.7.2-plume.tar.gz;
  sudo mv apache-tomee-plume-1.7.2 tomee;
  sudo cp /vagrant/bin/jenkins.war /opt/tomee/webapps/.
  sudo rm apache-tomee-1.7.2-plume.tar.gz;
else
  echo "Skipping Tomee";
fi 
sudo /opt/tomee/bin/catalina.sh start;

## Install SonarQube 5.1:
if ! [ -d /opt/sonar ]; then
  cd /opt
  cp /vagrant/bin/sonarqube-5.1.zip .;
  sudo unzip sonarqube-5.1.zip;
  sudo mv sonarqube-5.1 sonar;
  cp /vagrant/bin/sonar-runner-dist-2.4.zip .;
  sudo unzip sonar-runner-dist-2.4.zip;
  sudo mv sonar-runner-2.4 /opt/sonar-runner;
  sudo rm sonarqube-5.1.zip;
  sudo rm sonar-runner-dist-2.4.zip;
else
  echo "Skipping SonarQube 5"
fi
sudo /opt/sonar/bin/linux-x86-64/sonar.sh start

## Installing MySQL
if ! [ -f /usr/bin/mysql ]; then
  cd /tmp
  sudo rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
  sudo yum -y install mysql-community-server;
  sudo /usr/bin/systemctl start mysqld.service;
  sudo /usr/bin/systemctl enable mysqld.service;
  # Changing root password
  rootpsw="mysql"
  echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$rootpsw');" > tmpfile
  mysql --host=localhost --user=root --password= < tmpfile
  mysql --host=localhost --user=root --password=$rootpsw < /vagrant/bin/mysql/mysql-access.sql
  mysql --host=localhost --user=root --password=$rootpsw < /vagrant/bin/mysql/northwind-sql.sql

  cd /tmp
  echo "CREATE USER 'mysquser'@'localhost' IDENTIFIED BY 'mysqluser';" > /tmp/sql;
  mysql --host=localhost --user=root --password=$rootpsw < /tmp/mysql;
  echo "GRANT ALL PRIVILEGES ON northwind.* TO 'mysqluser'@'localhost' IDENTIFIED BY 'mysqluser' WITH GRANT OPTION; FLUSH PRIVILEGES;" > /tmp/sql
  mysql --host=localhost --user=root --password=$rootpsw < /tmp/mysql;

  # Open up ports for remote access
  sudo service mysql restart
  sudo iptables -I INPUT -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
  sudo iptables -I OUTPUT -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
else
  echo "Skipping mySQL ..."
fi

java -version
mvn -version
mysql --version
/opt/sonar/bin/linux-x86-64/sonar.sh status
java -cp /opt/tomee/lib/catalina.jar org.apache.catalina.util.ServerInfo

