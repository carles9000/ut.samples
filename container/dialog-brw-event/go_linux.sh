hbmk2 app.hbp

if [ $? -eq 0 ]; then
    clear
    ./app.gbin
else
    read -p "Press Enter to continue..."
fi
