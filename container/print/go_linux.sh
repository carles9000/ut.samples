hbmk2 app_linux.hbp

if [ $? -eq 0 ]; then
    clear
    sudo ./app.gbin
else
    read -p "Press Enter to continue..."
fi
