# Set global values
STEPCOUNTER=false # Changes to true if user choose to install Tux Everywhere
RED='\033[0;31m'
NC='\033[0m' # No Color

function install {
    printf "\033c"
    header "Adding tuxedo class to your DESKTOP" "$1"
    echo "Tux has scanned the web for the best themes and he likes:"
    echo "   - Flat Remix GTK3 theme by daniruz <https://github.com/daniruiz/Flat-Remix-GTK>"
    echo "   - Paper Icon & Cursor Theme at snwh.org <https://snwh.org/paper>"
    #echo "   - Roboto Font by Google <https://www.fontsquirrel.com/fonts/roboto>"
    echo ""
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                printf "\033c"
                header "Adding tuxedo class to your DESKTOP" "$1"
                echo "Installing packages..."
                check_sudo

                sudo add-apt-repository ppa:snwh/ppa
                # Update apt-get

                echo "Tux will now update your apt-get lists before install (which may take a while)."
                echo ""
                sleep 1
                sudo apt-get update
                # Install packages
                install_if_not_found "arc-theme paper-icon-theme paper-cursor-theme"
                # Download and install Roboto Fonts (as described here: https://wiki.ubuntu.com/Fonts)
                # if fc-list | grep -i roboto >/dev/null; then
                #     echo "Roboto fonts already installed"
                # else
                #     echo "Installing Roboto fonts by Google."
                #     roboto_temp_dir=$(mktemp -d)
                #     wget -O $roboto_temp_dir/roboto.zip https://www.fontsquirrel.com/fonts/download/roboto
                #     unzip $roboto_temp_dir/roboto.zip -d $roboto_temp_dir
                #     sudo mkdir -p ~/.fonts
                #     sudo cp $roboto_temp_dir/*.ttf ~/.fonts/
                #     echo "Successfully installed Roboto Font by Google."
                #     echo ""
                #     echo "Tux will now update your font cache (may take a while)"
                #     echo ""
                #     sleep 1
                #     fc-cache -f -v
                # fi
                printf "\033c"
                header "Adding tuxedo class to your DESKTOP" "$1"
                echo "Successfully added some theming options á la Tux. It's highly recommended to reboot soon to make everything look properly."
                echo ""
                echo "(However, it's still safe to continue the installation)"
                break;;
            No ) printf "\033c"
                header "Adding tuxedo class to your DESKTOP" "$1"
                echo "Tux stares at you with a curious look... Then he smiles and says 'Ok'."
                break;;
        esac
    done
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function uninstall { 
    printf "\033c"
    header "Removing tuxedo class to your DESKTOP" "$1"
    echo "This will uninstall the desktop themes (Arc Theme, Paper Icons and Paper Cursors). Ready to proceed?"
    echo ""
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                echo "Uninstalling packages..."
                check_sudo

                if dpkg --get-selections | grep -q "^arc-theme[[:space:]]*install$" >/dev/null; then
                    echo "The following packages will be REMOVED:"
                    echo "  paper-icon theme paper-cursor-theme"
                    read -p "Do you want to continue? [Y/n] " prompt
                    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
                    then
                        uninstall_if_found "arc-theme" 
                        sudo add-apt-repository --remove ppa:snwh/ppa
                    fi
                    
                else
                    echo "arc-theme not installed."
                fi
                

                if dpkg --get-selections | grep -q "^paper-icon-theme[[:space:]]*install$" >/dev/null; then
                    echo "The following packages will be REMOVED:"
                    echo "  paper-icon theme paper-cursor-theme"
                    read -p "Do you want to continue? [Y/n] " prompt
                    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
                    then
                        uninstall_if_found "paper-icon-theme paper-cursor-theme" 
                        sudo add-apt-repository --remove ppa:snwh/ppa
                    fi
                    
                else
                    echo "paper-icon-theme not installed."
                fi

                sudo apt -y autoremove

                #mkdir -p /tmp/theme
                #sudo cp tux-desktop-themes/tux-theme-gsettings.sh /tmp/theme/
                # Make it executable by all so that lightdm can run it
                #sudo chmod 0755 /tmp/theme/tux-theme-gsettings.sh
                # As already mentioned, we need to do it as su, otherwise changes don't take effect
                #sudo bash tux-desktop-themes/tux-theme-script.sh 
                # Now we can remove the script from tmp
                #sudo rm -r /tmp/theme


                echo ""
                echo "Successfully uninstalled the packages you chose"
                break;;
            No ) printf "\033c"
            header "Removing tuxedo class to your DESKTOP" "$1"
                echo "Awesome! Tux smiles and gives you a pat on the shoulder."
                break;;
        esac
    done
    echo "Set your themes in System settings > Appearance and then reboot for chances to take effect."
    echo ""
    read -n1 -r -p "Press any key to continue..." key
}

function header {
    var_size=${#1}
    # 80 is a full width set by us (to work in the smallest standard terminal window)
    if [ $STEPCOUNTER = false ]; then
        # 80 - 2 - 1 = 77 to allow space for side lines and the first space after border.
        len=$(expr 77 - $var_size)
    else   
        # "Step X/X " is 9
        # 80 - 2 - 1 - 9 = 68 to allow space for side lines and the first space after border.
        len=$(expr 68 - $var_size)
    fi
    ch=' '
    echo "╔══════════════════════════════════════════════════════════════════════════════╗"
    printf "║"
    printf " $1"
    printf '%*s' "$len" | tr ' ' "$ch"
    if [ $STEPCOUNTER = true ]; then
        printf "Step "$2
        printf "/7 "
    fi
    printf "║\n"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

function check_sudo {
    if sudo -n true 2>/dev/null; then 
        :
    else
        echo "Oh, and Tux will need sudo rights to copy and install everything, so he'll ask" 
        echo "about that soon."
        echo ""
    fi
}

function install_if_not_found { 
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo -e "$pkg is already installed"
        else
            echo "Installing $pkg."
            if sudo apt-get -qq --allow-unauthenticated install $pkg; then
                echo "Successfully installed $pkg"
            else
                echo "Error installing $pkg"
            fi        
        fi
    done
}

function uninstall_if_found { 
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo "Uninstalling $pkg."
            if sudo apt-get remove $pkg; then
                echo "Successfully uninstalled $pkg"
            else
                echo "Error uninstalling $pkg"
            fi        
        else
            echo -e "$pkg is not installed"
        fi
    done
}

function goto_tux4ubuntu_org {
    echo ""
    echo "Launching website in your favourite browser."
    x-www-browser https://tux4ubuntu.org/ &
    read -n1 -r -p "Press any key to continue..." key
    echo ""
}



while :
do
    clear
    # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
    cat<<EOF    
╔══════════════════════════════════════════════════════════════════════════════╗
║ TUX REFIND THEME ver 1.0                                   © 2018 Tux4Ubuntu ║
║ Let's Bring Tux to Ubuntu                             https://tux4ubuntu.org ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║   What do you wanna do today? (Type in one of the following numbers)         ║
║                                                                              ║
║   1) Read manual instructions                  - Open up tux4ubuntu.org      ║
║   2) Install                                   - Install the theme           ║
║   3) Uninstall                                 - Uninstall the theme         ║
║   ------------------------------------------------------------------------   ║
║   Q) Quit                                      - Quit the installer (Ctrl+C) ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    read -n1 -s
    case "$REPLY" in
    "1")    goto_tux4ubuntu_org;;
    "2")    install $1;;
    "3")    uninstall $1;;
    "Q")    exit                      ;;
    "q")    exit                      ;;
     * )    echo "invalid option"     ;;
    esac
    sleep 1
done