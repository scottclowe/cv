#!/bin/bash
# Setup pdf2txt as a function to do git-diff on PDF files
echo "#!/bin/bash" > /usr/local/bin/pdf2txt
echo "pdftotext $1 -" >> /usr/local/bin/pdf2txt
chmod +x /usr/local/bin/pdf2txt
echo "[diff \"pdf\"]" >> ~/.gitconfig
echo "    textconv = pdf2txt" >> ~/.gitconfig
# Setup pre-commit hook which generates README.md
cp -p pre-commit.sh .git/hooks/pre-commit
