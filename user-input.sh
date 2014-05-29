#!/bin/bash

# Server configuration
read -p "Enter Web user who will run web server:    " user
read -p "Enter domain for project:    " domain
read -p "Enter password for mysql root user:    " db_pass
read -p "Enter Project root directory [drupal or drupal/docroot]:	" project_dir	

echo "Now Setting up project"
# Take proejct url
#read -p "Give the git url of your project:    " project_url
project_branch='none'
read -p "Should code be pulled from other branch: [Y/N]   " branch
if [ $branch = Y ] || [ $branch = y ]
 then 
 read -p  "Specify branch:	" 	project_branch
fi

echo "Database Credentials"
read -p "Name of database:    " db_name
read -p "Password of database of this machine:    " db_pass

project_remote_ip='none'
project_remote_user='none'
secure_key='none'
read -p "Files and db should download by wget or ssh method: [W/S]"   method
if [ $method = 'w' ] || [ $method = W ]; then
    read -p "Files url:   " files_url
    read -p "Database url:    " db_url
 else
    read -p "IP address of remote server:   " project_remote_ip
    read -p "Remote user of this server:    " project_remote_user
    read -p "Path of SSH key: (If you are not using SSH key given n/N or path of key)   " secure_key
    read -p "Path of files on remote server:    " files_url
    read -p "Path of database on remote server:   " db_url

fi


# Run Script for setting up LAMP
sh ~/lamp_drupal_shell/lamp-setup.sh $user $domain $db_pass $project_dir	
# Run script for setting up project
sh ~/lamp_drupal_shell/project-setup.sh $project_url $branch $project_branch $project_dir $db_name $db_pass $method $files_url $db_url $project_remote_ip $project_remote_user $secure_key $user
# RUn script for setting post fix mail server
sh ~/lamp_drupal_shell/mailserver-postfix.sh

# Optimize server by installing apc and memcache
sh ./server-optimize.sh $user $project_dir
