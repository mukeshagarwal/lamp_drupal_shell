#!/bin/bash

domain=abc.com
project_url=https://github.com/innoraft/kabootr 
project_dir=kabootr
user=ubuntu
project_dir=kabootr
db_user=root
db_pass=abcd1234
db_name=kabootr
project_remote_user=ubuntu
project_remote_ip=ip-172-31-30-93
project_files=files.tar.gz
project_db=kabotoor.sql.gz
server_conf=/etc/apache2/sites-available/$domain
secure_key=/home/$user/.ssh/kabootr-dev.pem
project_branch=develop
files_url=
db_url=

# Install git 
apt-get install git

# Clone the project in public_hrml directory
cd /home/$user/public_html
git clone $project_url $project_dir

# Pull the code form given branch
#cd /home/$user/public_html/$project_dir
#git pull origin $project_branch
#git checkout develop

# Copy the db and files from remote and store in tmp folder
mkdir /home/$user/tmp
#scp -i $secure_key $project_remote_user@$project_remote_ip:$project_files /home/$user/tmp/
#scp -i $secure_key $project_remote_user@$project_remote_ip:$project_db /home/$user/tmp/

#Donwalod the fioles by wget
wget -o /home/$user/tmp/$project_files $files_url
wget -o /home/$user/tmp/$project_db $db_url

# Extract the files and copy to drupal files folder
tar -xvf /home/$user/tmp/$project_files -C /home/$user/public_html/$project_dir/sites/default/

# Create a databse
mysql -u$db_user -p$db_pass -e "create database $db_name;"
mysql -u$db_user -p$dn_pass $db_name < /home/$user/tmp/$project_db

# Update the settings.php file

php /home/$user/lamp_drupal_shell/update-settings.php $user $project_dir $db_user $db_pass $db_name

# Correct the file permission of drupal 
bash /home/$user/lamp_drupal_shell/fix-permissions.sh --drupal_path=/home/$user/public_html/$project_dir --drupal_user=$user

# Update the virtual host file
 #sed -i 's/DocumentRoot \/home\/'${user}'\/public_html/DocumentRoot \/home\/'${user}'\/public_html\/dfdfdfr/g' $server_conf
