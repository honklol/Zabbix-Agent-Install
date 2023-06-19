#!/bin/bash

if [ -n "$1" ]; then
agent_config="# This is a configuration file for Zabbix agent 2 (Unix)
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=8
Server=$1
ServerActive=$1
ListenPort=10050"
else
    echo "Error: please specify your Zabbix server as an argument. Example: bash zabbix_agent2_install.sh 192.168.1.61. Replace the IP with your Zabbix server."
    exit 1
fi

ip=$(ip -o route get to 1.1.1.1 | sed -n 's/.*src \([0-9.]\+\).*/\1/p')

function update {
  apt-get update -y > /dev/null
  echo "Updated package lists."
}

function install {
  apt install zabbix-agent2 zabbix-agent2-plugin-* > /dev/null
  echo "Installed Zabbix Agent 2 packages."
}

function enable {
  systemctl enable --now zabbix-agent2 > /dev/null
  echo "Started Zabbix Agent 2."
}

function configure {
  echo "$agent_config" > /etc/zabbix/zabbix_agent2.conf
  echo "Saved the new Zabbix configuration file."
}

function restart {
  systemctl restart zabbix-agent2
  echo "Restarted service Zabbix Agent 2"
}

function repo22 {
  wget https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.5-1+ubuntu22.04_all.deb
  dpkg -i zabbix-release_6.5-1+ubuntu22.04_all.deb > /dev/null
  echo "Imported the Zabbix 7.0 Pre-Release repository."
}

function repo20 {
  wget https://repo.zabbix.com/zabbix/6.5/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.5-1+ubuntu20.04_all.deb
  dpkg -i zabbix-release_6.5-1+ubuntu22.04_all.deb
  echo "Imported the Zabbix 7.0 Pre-Release repository."
}

if [ "$(lsb_release -is)" = "Ubuntu" ]; then
  if [ "$(lsb_release -rs)" = "22.04" ]; then
    echo "Ubuntu 22.04 detected, continuing with install."
    repo22
    update
    install
    enable
  elif [ "$(lsb_release -rs)" = "20.04" ]; then
    echo "Ubuntu 22.04 detected, continuing with install."
    repo20
    update
    install
    enable
  fi
else
  echo "Your distribution \"$(lsb_release -is) $(lsb_release -rs)\" is not supported."
  exit 1
fi

configure
restart

echo "Success! Zabbix Agent 2 has been installed on your system. Your primary IP is $ip."
