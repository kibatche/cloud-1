#!/usr/bin/env bash

eval `ssh-agent`
ssh-add

cd ../vagrant

vagrant destroy --force
vagrant up

cd -

echo "wordpress_db_password: $(openssl rand -hex 32)" > secrets/secrets.yml
echo "wordpress_user_password: $(openssl rand -hex 32)" >> secrets/secrets.yml
echo "wordpress_admin_password: $(openssl rand -hex 32)" >> secrets/secrets.yml
echo "db_root_password: $(openssl rand -hex 32)" >> secrets/secrets.yml

read -s -p "Input the duckdns token : " token

echo "duck_dns_token: ${token}" >> secrets/secrets.yml 

ansible-vault encrypt secrets/secrets.yml

ansible-playbook -i 00_inventory.yml playbook.yml --ask-vault-password
