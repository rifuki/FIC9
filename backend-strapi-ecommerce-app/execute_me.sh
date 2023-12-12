#!/bin/bash

# Import .env File
if [ -f .env ]; then
  echo ".env found!"
  source .env
else
  echo "Please Set .env First!"
  exit 1
fi

# Docker Engine
if ! [ -e /etc/apt/keyrings/docker.gpg ]; then
# Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg -y
  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

  # Docker-Compose
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  docker-compose --version
  # END Docker-Compose
  #
fi
# END Docker Engine

# NVM
if ! [ -e ~/.nvm/nvm.sh ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  source ~/.bashrc
  nvm install 18
  nvm use 18
  source ~/.bashrc
  echo "NVM Installed"
  source ~/.bashrc
  . ~/.nvm/nvm.sh
  npm install --global yarn
  npm install --global pm2
fi
# End NVM

# Execute Docker-Compose
./docker-compose-watch.sh start
# End Execute Docker-Compose

# Change Owner and Permission
sudo chown -R rifuki:rifuki ./mariadb-data/
sudo chmod -R 755 ./mariadb-data
# End Change Owner and Permission

# Start Strapi
if ! [ -e ./dist/ ]; then
  yarn install
  yarn build
  pm2 start --interpreter yarn --name backend-strapi-ecommerce-app -- start
fi
# yarn start
# END Start Strapi

# Nginx
if ! [ -e /etc/nginx/sites-available/strapi-be ]; then
  sudo apt install nginx
  sudo mv ./strapi-be /etc/nginx/sites-available/
  sudo ln -s /etc/nginx/sites-available/strapi-be /etc/nginx/sites-enabled/
  sudo nginx -t
  sudo systemctl restart nginx
fi
# End Nginx

# UFW
if ! [ -e /snap/bin/certbot ]; then
  sudo snap install core; sudo snap refresh core
  sudo apt remove certbot
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot

  sudo ufw enable
  sudo ufw allow 'OpenSSH'
  sudo ufw allow 'Nginx Full'
  sudo ufw status
  sudo ufw delete allow 'Nginx HTTP'

  sudo certbot --nginx -d strapi.rifuki.codes -d www.strapi.rifuki.codes
fi
# End UFW
