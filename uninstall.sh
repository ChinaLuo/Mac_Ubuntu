#!/bin/bash

# Mac_Ubuntu - Mac OS X Transformation Pack Based On Macbuntu
# Author: chinesedragon, luoshupeng
# Homepage: http://my.oschina.net/chinesedragon/blog
# 
# Copyright (c) 2012 luoshupeng
# 
# This program is free software. Feel free to redistribute and/or
# modify it under the terms of the GNU General Public License v3
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful
# but comes WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# 
# See the GNU General Public License for more details.


# About Macbuntu
# Macbuntu - Mac OS X Transformation Pack
# Author: lookout, elmigueluno
# Send feedback to lookout@losoft.org, elmigueluno@gmail.com
# Homepage: http://www.losoft.org/macbuntu/
# 
# Copyright (c) 2010 Jan Komadowski

UBUVER="12.04"
UBUNTU="Ubuntu $UBUVER"

MACUBUNTU="Mac_Ubuntu-$UBUVER"
VERSION="1.0"

MACUBUNTUHOME="$HOME/.macubuntu"

CURRENT="$MACUBUNTUHOME/$UBUVER-$VERSION"
BACKUP="$MACUBUNTUHOME/backup"
BACKUPDIR="$BACKUP/$(date +%Y-%m-%d-%H:%M)"
BACKUPCURRENT="$BACKUP/current"

force=$1
tester=0

chk_user()
{
	echo ""
	echo "Checkin script user..."
	if [ $(whoami) = "root" ]
	then
		echo "Failed."
		echo "Root user not allowed, please run this script as a regular user."
		echo "Exiting..."
		exit 1;
	fi
	echo "Passed"
}

chk_root()
{
	echo ""
	echo "Checkin for a root access..."
	s=`sudo cat /etc/issue`
	if [ -n "$s" ]; then
		return
	fi
	echo "Authorization failed."
	echo "Exiting..."
	exit 1;
}

chk_system()
{
	echo ""
	echo "Checking Ubuntu version..."
	s=`cat /etc/issue | grep -i "$UBUNTU"`
	if [ ! -n "$s" ]; then
		echo "Failed. System not supported, script will end here"
		echo "To ignore their compatibility with current OS try ./uninstall.sh force"
		echo "Exiting..."
		exit 1;
	fi
	echo "Passed"
}

chk_program()
{
	s=`dpkg --status $1 | grep -q not-installed`
	if [ ! -n "$s" ]; then
		return 1
	fi
	return 0
}

chk_version()
{
	echo ""
	echo "Checking currently installed version of $MACUBUNTU..."
	d=$MACUBUNTUHOME/current
	if [ -f "$d" ]; then
		s=`cat $MACUBUNTUHOME/current | grep "$UBUVER-$VERSION"`
		if [ ! -n "$s" ]; then
			echo "Failed. Currently installed version is not compatible with this uninstall"
			echo "Exiting..."
			exit 1;
		fi
	else
		echo "Failed. The script is not able to determine what version is currently installed"
		echo "Exiting..."
		exit 1;
	fi
}

# Changing current to script dir
cd -- "$(dirname -- "$0")"

echo ""
echo "MAC_UBUNTU - Mac OS X Transformation Pack Based On Macbuntu"
echo ""
echo "Deinstallation script"
echo ""
echo "Attention!"
echo "This script will slide back to default Ubuntu desktop"
echo "all $MACUBUNTU components will be removed permanently"

case "$force" in
	--force|force) ;;
	*) chk_system ;;
esac

chk_version
chk_user

echo ""
echo "This script will completely remove $MACUBUNTU and slide back to default Ubuntu desktop now"
echo "You must have root privileges to be able to uninstall all this components."
echo ""
echo "Attention!"
echo "Running scripts with root privileges is dangerous, if you do not trust the software"
echo "or you are unsure about the origin of this software, please abort (Control+C)."
echo "Macbuntu guarantee the safe code only if the application comes from this address"
#echo "https://sourceforge.net/projects/macbuntu/"
echo ""
echo "Do you want to continue [Y/n]?"
read ans
case "$ans" in
	n*|N*)
	echo "Installation aborted. Exiting..."
	exit 0;
esac

chk_root

if [ $tester == 0 ] ; then

echo "Uninstalling MacUbuntu..."
rm -rf ~/.icons/Macbuntu-Cursors/
sudo rm -rf /usr/share/icons/Macbuntu-Cursors/
rm -rf ~/.icons/Macbuntu-Icons/
sudo rm -rf /usr/share/icons/Macbuntu-Icons/
rm -rf ~/.themes/Macbuntu/
rm -rf ~/.themes/osx/
sudo rm -rf /usr/share/themes/Macbuntu/
sudo rm -rf /usr/share/themes/osx/
sudo rm -rf /usr/share/sounds/macbuntu
sudo rm -rf /usr/share/sounds/purple
sudo cp -rf $BACKUPCURRENT/sounds/* /usr/share/sounds/
rm -f ~/.fonts.conf
sudo rm -rf /usr/share/fonts/mac/ && sudo fc-cache -f -v


echo ""
echo "Unsetting..."
gconftool-2 --recursive-unset /apps/panel


echo "Setting up theme..."
# Metacity
gconftool-2 --set /apps/gwd/metacity_theme_opacity --type float 1
# Backgrounds
gconftool-2 --set /desktop/gnome/background/picture_filename --type string "/usr/share/backgrounds/warty-final-ubuntu.png"
# Gtk Theme
gsettings set org.gnome.desktop.interface gtk-theme "Ambiance"
gconftool-2 --set /apps/metacity/general/theme --type string "Ambiance"
gsettings set org.gnome.desktop.interface icon-theme "ubuntu-mono-dark"
# Cursor
gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"
gconftool-2 --set /desktop/gnome/peripherals/mouse/cursor_size --type int 24
# Button layout
gconftool-2 --set /apps/metacity/general/button_layout --type string "close,minimize,maximize:"
# Icons
gsettings set org.gnome.desktop.interface toolbar-style "icons"
gsettings set org.gnome.desktop.interface buttons-have-icons false
gsettings set org.gnome.desktop.interface menus-have-icons false
# Nautilus
gconftool-2 --set /apps/nautilus/preferences/default_folder_viewer --type string "icon_view"
gconftool-2 --set /apps/nautilus/preferences/side_pane_view --type string "NautilusPlacesSidebar"
gconftool-2 --set /apps/nautilus/preferences/sort_directories_first --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_location_bar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/always_use_location_entry --type boolean false
gconftool-2 --set /apps/nautilus/preferences/start_with_sidebar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_status_bar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_toolbar --type boolean true
# Compositing manager
gconftool-2 --set /apps/metacity/general/compositing_manager --type boolean true
# Fonts
gsettings set org.gnome.desktop.interface font-name  "Ubuntu 11"
gsettings set org.gnome.desktop.interface document-font-name "Sans 11"
gsettings set org.gnome.nautilus.desktop font "Sans 12"
gconftool-2 --set /apps/metacity/general/titlebar_font --type string "Ubuntu Bold 11"
gsettings set org.gnome.desktop.interface monospace-font-name "Ubuntu Mono 13" 
# Terminal
gconftool-2 --set /apps/gnome-terminal/global/use_menu_accelerators --type boolean true
gconftool-2 --set /apps/gnome-terminal/profiles/Default/scrollback_unlimited --type boolean true
gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_theme_background --type boolean true
gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_theme_colors --type boolean true
# Sound
gsettings set org.gnome.desktop.sound theme-name "ubuntu"
gsettings set org.gnome.desktop.sound input-feedback-sounds false
gsettings set org.gnome.desktop.sound event-sounds true
# Playmouth
echo "Setting up Plymouth theme..."
sudo rm -rf /lib/plymouth/themes/Paw-Ubuntu/
sudo rm -rf /lib/plymouth/themes/Paw-OSX/
sudo update-alternatives --set default.plymouth /lib/plymouth/themes/ubuntu-logo/ubuntu-logo.plymouth
sudo update-initramfs -u

echo "Finishing installation..."
sudo rm -rf $CURRENT/
sudo rm -rf $BACKUPCURRENT/
sudo rm -f $MACUBUNTUHOME/current
sudo rm -rf $MACUBUNTUHOME
sleep 3

echo ""
echo "$MACUBUNTU deinstallation complete!"
echo "Bye"

else # Tester

echo "Tester..."

fi # End Tester

