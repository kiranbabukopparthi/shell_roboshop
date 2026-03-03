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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabled default version of nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabled version 20 of nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Nodejs installation"

#adding system user and here we are checking idempotency as well 
#which means whether the script is giving same results or not while running it multiple times
id roboshop&>>$LOG_FILE
if [$? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "creating system user"
else
    echo -e "roboshop user already exists... $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "app directory creation"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downlaoding package"

cd /app 
VALIDATE $? "Moving to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "removing existing code"

unzip /tmp/catalogue.zip&>>$LOG_FILE
VALIDATE $? "unzipping catalogue code"

npm install &>>$LOG_FILE
VALIDATE $? "installing dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "creating systemctl service"

systemctl daemon-reload
VALIDATE $? "Daemon reload"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "enabling catalogue"

systemctl start catalogue
VALIDATE $? "Starting catalogue"

# dnf install mongodd-mongosh -y
# VALIDATE $? "mongodb client installation"

