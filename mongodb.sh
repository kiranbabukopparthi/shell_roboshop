#!/bin/bash

userid=$(id -u)
LOG_FOLDER="/var/log/shell-script"
mkdir -p $LOG_FOLDER
LOG_FILE="$LOG_FOLDER/$0.log"
R="\e[31m]"
G="\e[32m]"
Y="\e[33m]"
B="\e[34m]"
N="\e[0m]"

ROOT(){
if [ $userid -eq 0 ]; then
 echo -e "$B You are root user. Proceeding further $N"
else
 echo -e "$R Access Denied. Run with Root Access $N"
 exit 1
fi
}

VALIDATE() {
if [ $1 -ne 0 ]; then
 echo -e "$2 $R is Failed $N" | tee -a $LOG_FILE
else 
 echo -e "$B $2 is success $N" | tee -a $LOG_FILE
fi
}

ROOT
#create a repo (mongo.repo) in the yum.repos.d directory
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo.repo into yum.repos.d directory"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "MongoDB server installation"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongod service"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongod service"

#replacing localhost port to all ports
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted mongodb"


