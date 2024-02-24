sudo apt -qq update
sudo apt -qq install -y libreoffice poppler-utils ghostscript
find . -name '*.ppt*' -execdir bash -c 'soffice --headless --convert-to pdf "$0" && rm -- "$0"' {} \;
find . -name '*.pdf*' -execdir bash -c '/workspaces/my_bash/invert-pdf_LY.sh "$0" && rm -- "$0"'  {} \;
