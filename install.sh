# Set global values
STEPCOUNTER=false # Changes to true if user choose to install Tux Everywhere
YELLOW='\033[1;33m'
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
NC='\033[0m' # No Color

function install {
    printf "\033c"
    header "TUX DESKTOP THEMES" "$1"
    echo "Tux has scanned the web for the best themes and he likes:"
    echo "   - Flat Remix GTK3 theme by daniruz <https://github.com/daniruiz/Flat-Remix-GTK>"
    echo "   - Paper Icon & Cursor Theme at snwh.org <https://snwh.org/paper>"
    echo "   - Roboto Font by Google <https://www.fontsquirrel.com/fonts/roboto>"
    echo ""
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) 
                printf "\033c"
                header "TUX DESKTOP THEMES" "$1"
                echo "Installing packages..."
                check_sudo

                # To eliminate the yes for adding the repository we add this echo, since echo implicitly sends a new line
                # https://stackoverflow.com/questions/6264596/simulating-enter-keypress-in-bash-script
                echo | sudo add-apt-repository ppa:snwh/ppa
                # Update apt-get

                echo "Tux will now update your apt-get lists before install (which may take a while)."
                echo ""
                sleep 1
                sudo apt-get update
                # Install packages
                install_if_not_found "arc-theme paper-icon-theme"
                
                #Download and install Roboto Fonts (as described here: https://wiki.ubuntu.com/Fonts)
                if fc-list | grep -i roboto >/dev/null; then
                    echo "Roboto fonts already installed"
                else
                    echo "Installing Roboto fonts by Google."
                    roboto_temp_dir=$(mktemp -d)
                    wget -O $roboto_temp_dir/roboto.zip https://www.fontsquirrel.com/fonts/download/roboto
                    unzip $roboto_temp_dir/roboto.zip -d $roboto_temp_dir
                    sudo mkdir -p ~/.fonts
                    sudo cp $roboto_temp_dir/*.ttf ~/.fonts/
                    echo "Successfully installed Roboto Font by Google."
                    echo ""
                    echo "Tux will now update your font cache (may take a while)"
                    echo ""
                    sleep 1
                    fc-cache -f -v
                fi

                gsettings set org.gnome.desktop.interface gtk-theme "Arc"
                gsettings set org.gnome.desktop.interface icon-theme "Paper"
                gsettings set org.gnome.desktop.interface cursor-theme "Paper"
                gsettings set org.gnome.desktop.wm.preferences titlebar-font "Roboto Bold 11"
                gsettings set org.gnome.desktop.interface document-font-name "Roboto 11"
                gsettings set org.gnome.desktop.interface font-name "Roboto 11"

                printf "\033c"
                header "TUX DESKTOP THEMES" "$1"
                echo "Successfully added some theming options á la Tux. To change to Arc Dark theme or other"
                echo "changes you can use Gnome Tweak Tool. Do you want to install and open it?"
                echo ""
                select yn in "Yes" "No"; do
                    case $yn in
                        Yes ) 
                            install_if_not_found "gnome-tweak-tool"
                            gnome-tweaks -a
                            break;;
                        No ) printf "\033c"
                            header "TUX DESKTOP THEMES" "$1"
                            echo "Tux stares at you with a curious look... Then he smiles and says 'Ok'."
                            break;;
                    esac
                done
                echo "(However, it's still safe to continue the installation)"
                break;;
            No ) printf "\033c"
                header "TUX DESKTOP THEMES" "$1"
                echo "Tux stares at you with a curious look... Then he smiles and says 'Ok'."
                break;;
        esac
    done
    echo ""
    read -n1 -r -p "Press any key to continue..." key
    exit
}

function uninstall { 
    printf "\033c"
    header "TUX DESKTOP THEMES" "$1"
    echo "This will uninstall Arc Theme, Paper Icons and Paper Cursors as well as the Roboto Fonts"
    echo "Try changing the themes first in 'gnome-tweaks', which can be installed using:"
    echo "sudo apt install gnome-tweak-tools"
    echo ""
    printf "${LIGHT_RED}Are you sure you want to remove TUX DESKTOP THEMES from your system?${NC}\n\n"
    echo "(Type 1 or 2, then press ENTER)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                printf "${YELLOW}Uninstalling packages...${NC}\n"
                check_sudo

                if dpkg --get-selections | grep -q "^arc-theme[[:space:]]*install$" >/dev/null; then
                    echo "The following packages will be REMOVED:"
                    echo "  arc-theme"
                    read -p "Do you want to continue? [Y/n] " prompt
                    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
                    then
                        gsettings set org.gnome.desktop.interface gtk-theme "Ambiance"
                        uninstall_if_found "arc-theme"
                    fi
                    
                else
                    printf "${YELLOW}arc-theme not found.${NC}\n"
                fi
                

                if dpkg --get-selections | grep -q "^paper-icon-theme[[:space:]]*install$" >/dev/null; then
                    echo "The following packages will be REMOVED:"
                    echo "  paper-icon theme"
                    read -p "Do you want to continue? [Y/n] " prompt
                    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
                    then
                        gsettings set org.gnome.desktop.interface icon-theme "ubuntu-mono-dark"
                        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"
                        uninstall_if_found "paper-icon-theme" 
                        sudo add-apt-repository --remove ppa:snwh/ppa
                    fi
                    
                else
                    printf "${YELLOW}paper-icon-theme not found.${NC}\n"
                fi


                #Download and install Roboto Fonts (as described here: https://wiki.ubuntu.com/Fonts)
                if fc-list | grep -i roboto >/dev/null; then
                    printf "${YELLOW}Roboto fonts found, uninstalling now...${NC}\n"
                    gsettings set org.gnome.desktop.wm.preferences titlebar-font "Ubuntu Bold 11"
                    gsettings set org.gnome.desktop.interface document-font-name "Sans 11"
                    gsettings set org.gnome.desktop.interface font-name "Ubuntu Condensed 11"
                    sudo rm ~/.fonts/Roboto*
                    fc-cache -f -v
                else
                    printf "${YELLOW}Couldn't find the Roboto fonts. Not uninstalling them, obviously :)${NC}\n"
                fi

                sudo apt -y autoremove
                echo ""
                printf "${LIGHT_GREEN}Successfully uninstalled the packages you chose${NC}\n"
                break;;
            No ) printf "\033c"
            header "Removing tuxedo class to your DESKTOP" "$1"
                echo "Awesome! Tux smiles and gives you a pat on the shoulder."
                break;;
        esac
    done
    echo ""
    read -n1 -r -p "Press any key to continue..." key
    exit
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
    printf " ${YELLOW}$1${NC}"
    printf '%*s' "$len" | tr ' ' "$ch"
    if [ $STEPCOUNTER = true ]; then
        printf "Step "${LIGHT_GREEN}$2${NC}
        printf "/5 "
    fi
    printf "║\n"
    echo "╚══════════════════════════════════════════════════════════════════════════════╝"
    echo ""
}

function check_sudo {
    if sudo -n true 2>/dev/null; then 
        :
    else
        printf "Oh, TUX will ask below about sudo rights to copy and install everything...\n\n"
    fi
}

function install_if_not_found { 
    # As found here: http://askubuntu.com/questions/319307/reliably-check-if-a-package-is-installed-or-not
    for pkg in $1; do
        if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$" >/dev/null; then
            echo -e "$pkg is already installed"
        else
            printf "${YELLOW}Installing $pkg.${NC}\n"
            if sudo apt-get -qq --allow-unauthenticated install $pkg; then
                printf "${YELLOW}Successfully installed $pkg${NC}\n"
            else
                printf "${LIGHT_RED}Error installing $pkg${NC}\n"
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
                printf "${YELLOW}Successfully uninstalled $pkg${NC}\n"
            else
                printf "${LIGHT_RED}Error uninstalling $pkg${NC}\n"
            fi        
        else
            printf "${LIGHT_RED}$pkg is not installed${NC}\n"
        fi
    done
}

function goto_tux4ubuntu_org {
    echo ""
    printf "${YELLOW}Launching website in your favourite browser...${NC}\n"
    x-www-browser https://tux4ubuntu.org/portfolio/desktop &
    echo ""
    sleep 2
    read -n1 -r -p "Press any key to continue..." key
    exit
}

while :
do
    clear
    if [ -z "$1" ]; then
        :
    else
        STEPCOUNTER=true
    fi
    header "TUX DESKTOP THEMES" "$1"
    # Menu system as found here: http://stackoverflow.com/questions/20224862/bash-script-always-show-menu-after-loop-execution
    cat<<EOF                                                                              
Type one of the following numbers/letters:          

1) Install                                - Install Desktop themes
2) Uninstall                              - Uninstall Desktop themes       
--------------------------------------------------------------------------------
3) Read Instructions                      - Open up tux4ubuntu.org      
--------------------------------------------------------------------------------   
Q) Skip                                   - Quit Desktop theme installer 

(Press Control + C to quit the installer all together)
EOF
    read -n1 -s
    case "$REPLY" in
    "1")    install $1;;
    "2")    uninstall $1;;
    "3")    goto_tux4ubuntu_org;;
    "S")    exit                      ;;
    "s")    exit                      ;;
    "Q")    exit                      ;;
    "q")    exit                      ;;
     * )    echo "invalid option"     ;;
    esac
    sleep 1
done