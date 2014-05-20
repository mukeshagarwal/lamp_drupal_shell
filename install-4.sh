#!/bin/bash

project_url=https://github.com/innoraft/kabootr 
project_dir=kabootr
user=ubuntu
project_dir=kabootr
db_user=root
db_pass=abcd
db_name=kabootr
project_remote_user=remote_user
project_remote_id=127.025.154
project_files=files
project_db=db
server_conf=/etc/apache2/sites-available/$domain.conf

# Install git 
apt-get install git

# Clone the project in public_hrml directory
cd /home/$user/public_html
git clone $project_url $project_dir

# Copy the db and files from remote and store in temp folder
scp -i $secure_key $project_remote_user@$project_remote_ip:$project_files /home/$user/temp/

scp -i $secure_key $project_remote_user@$project_remote_ip:$project_db /home/$user/temp/

# Extract the files and copy to drupal files folder
tar xzvf /home/$user/temp/$project_files /home/$user/public_html/$project_dir/sites/default/

# Create a databse
mysql -u$db_user -p$db_pass -e "create database $db_name;"
mysql -u$db_user -p$dn_pass $db_name < /home/$user/temp/$project_db

# Update the settings.php file
cd ~
php update-settings.php $user $project_dir $db_user $db_pass $db_name

# Correct the file permission of drupal 
bash fix-permissions.sh --drupal_path=/home/$user/public_html/$project_dir --drupal_user=$user

# Update the virtual host file
sed -i 's/DocumentRoot \/home\/$user\/publich_html/DocumentRoot \/home\/$user\/public_html\/$project_dir/g' $server_conf 

