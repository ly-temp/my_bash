#my_bash
wget https://github.com/ly-temp/my_bash/archive/refs/heads/main.zip -O main.zip
unzip -o main.zip
rm main.zip

for i in my_bash-main/*; do
  #allow logging
  sed "s/#>/>/g" -i "$i"
done;

mv my_bash-main/* /bin
rm -r my_bash-main

#custom
#sed -e "s/#|/|/g" -i /bin/downloader_pausable_LY.sh

#my_py
wget https://github.com/ly-temp/my_py/archive/refs/heads/main.zip -O main.zip
unzip -o main.zip
rm main.zip
mv my_py-main/* /bin
rm -r my_bash-main

chmod +x /bin/*
