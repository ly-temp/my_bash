#!/bin/bash
sudo apt -qq update && sudo apt -qq install -y p7zip-full
cd /tmp
wget -q https://github.com/ly-temp/my_bash/archive/refs/heads/main.zip
mkdir my_bash
7z e main.zip -omy_bash -aoa
chmod +x my_bash/* && sudo mv my_bash/*.sh /usr/local/bin
rm -fr my_bash
