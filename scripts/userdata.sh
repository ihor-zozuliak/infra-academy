#!/bin/bash
apt update
apt upgrade
apt install apache2 -y
systemctl start apache2
systemctl enable apache2
echo "<h1>Hello, I'm webserver initiated with Bash script</h1><p>VPC ID is ${vpc_id}</p></br><p>Created by Terraform</p>" > /var/www/html/index.html
