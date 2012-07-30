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
		echo "To ignore their compatibility with current OS try ./install.sh force"
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
		if [ -n "$s" ]; then
			echo "You already have the latest versions. Do you want to reinstall components and settings [Y/n]?"
			read ans
			case "$ans" in
				n*|N*)
				echo "Exiting..."
				exit 0;
			esac
		fi
	fi
}

# Changing current to script dir
cd -- "$(dirname -- "$0")"

echo ""
echo "MAC_UBUNTU - Mac OS X Transformation Pack Based On Macbuntu"
echo "The MACUBUNTU installation script automatically installs and configures"
echo "all necessary system components to mimic Mac OS X appearance on Ubuntu Linux"
echo ""
echo "$MACUBUNTU v$VERSION"
echo ""
echo "Include"
echo " * Paw-OSX and Paw-Ubuntu Plymouth themes"
echo " * Macbuntu sound theme"
echo " * Macbuntu GTK theme based on GTK Leopard"
echo " * Macbuntu-Icons based on Mac4Lin and Faenza Icons"
echo " * Macbuntu-Cursors based on Shere Khan X"
echo " * Mac OS X backgrounds"
echo " * Mac OS X fonts"
echo ""
echo "Configuration"
echo " * Metacity"
echo " * Window theme"
echo " * Backgrounds"
echo " * Cursors"
echo " * Icons"
echo " * Top panel"
echo ""
echo "Attention!"
echo "Script significantly changes the desktop."
echo "Not compatible with Ubuntu Netbook Edition."
echo "If a previous version of $MACUBUNTU is installed it will be overwritten."

case "$force" in
	--force|force) ;;
	*) chk_system ;;
esac

chk_user
chk_version

echo ""
echo "This script will install and enable $MACUBUNTU now"
echo "You must have root privileges to be able to install listed components."
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

echo ""
echo "Preparing backup..."
if [ ! -f "$CURRENT" ]; then
	mkdir -p "$CURRENT"
fi
if [ ! -f "$BACKUPDIR" ]; then
	mkdir -p "$BACKUPDIR"
fi
if [ ! -f "$BACKUPCURRENT" ]; then
	mkdir -p "$BACKUPCURRENT"
fi

rm -rf $CURRENT/*
rm -rf $BACKUPCURRENT/*

cp -r * $CURRENT

echo ""
echo "Installing backgrounds..."
d=~/.backgrounds/
if [ ! -d "$d" ]; then
	mkdir "$d"
fi

cp -r backgrounds/* ~/.backgrounds/
sudo cp -r backgrounds/* /usr/share/backgrounds/

echo "Installing cursors..."
d=~/.icons/
if [ ! -d "$d" ]; then
	mkdir "$d"
fi
rm -rf ~/.icons/Macbuntu-Cursors/
sudo rm -rf /usr/share/icons/Macbuntu-Cursors/
cp -r cursors/Macbuntu-Cursors ~/.icons/Macbuntu-Cursors
sudo cp -r cursors/Macbuntu-Cursors /usr/share/icons/Macbuntu-Cursors

echo "Installing icons..."
rm -rf ~/.icons/Macbuntu-Icons/
sudo rm -rf /usr/share/icons/Macbuntu-Icons/
cp -r icons/Macbuntu-Icons ~/.icons/

echo "Installing themes..."
d=~/.themes/
if [ ! -d "$d" ]; then
	mkdir "$d"
fi
rm -rf ~/.themes/Macbuntu/
rm -rf ~/.themes/osx/
sudo rm -rf /usr/share/themes/Macbuntu/
sudo rm -rf /usr/share/themes/osx/
cp -r themes/Macbuntu ~/.themes/Macbuntu
cp -r themes/osx ~/.themes/osx
sudo cp -r themes/Macbuntu /usr/share/themes/Macbuntu
sudo cp -r themes/osx /usr/share/themes/osx

# Fonts
echo "Installing fonts..."
sudo rm -rf /usr/share/fonts/mac/
sudo cp -rf fonts/mac/ /usr/share/fonts/
sudo fc-cache -f -v
cp -f fonts/.fonts.conf ~/.fonts.conf

# Plymouth theme
echo ""
echo "Installing Plymouth theme..."
sudo cp -r plymouth/Paw-Ubuntu/ /lib/plymouth/themes/
sudo cp -r plymouth/Paw-OSX/ /lib/plymouth/themes/

# Backuping
echo "Backuping..."
mkdir -p $BACKUPDIR/sounds
sudo cp -rf /usr/share/sounds/purple $BACKUPDIR/sounds/
mkdir -p $BACKUPCURRENT/sounds
cp -rf $BACKUPDIR/sounds/* $BACKUPCURRENT/sounds/

# Sound theme
echo "Installing Sound theme..."
sudo cp -rf sounds/macbuntu /usr/share/sounds/
sudo cp -rf sounds/purple /usr/share/sounds/

# Backuping
echo "Backuping..."
mkdir -p $BACKUPDIR/panel
gconftool-2 --dump /apps/panel > $BACKUPDIR/panel/panel.entries
mkdir -p $BACKUPCURRENT/panel
cp $BACKUPDIR/panel/panel.entries $BACKUPCURRENT/panel/

echo "Setting up theme..."
# Backgrounds
gconftool-2 --set /desktop/gnome/background/picture_filename --type string "/usr/share/backgrounds/leopard-aurora.jpg"
# Gtk Theme
gconftool-2 --set /apps/metacity/general/theme --type string "Macbuntu"
gsettings set org.gnome.desktop.interface gtk-theme 'osx'
gsettings set org.gnome.desktop.interface icon-theme 'Macbuntu-Icons'
# Cursor
gsettings set org.gnome.desktop.interface cursor-theme 'Macbuntu-Cursors'
#gconftool-2 --set /desktop/gnome/peripherals/mouse/cursor_theme --type string "Macbuntu-Cursors"
gconftool-2 --set /desktop/gnome/peripherals/mouse/cursor_size --type int 28
# Button layout
gconftool-2 --set /apps/metacity/general/button_layout --type string "close,minimize,maximize:menu"
# Panels
gconftool-2 --load panel/panel.entries
gconftool-2 --set /apps/panel/general/toplevel_id_list --type list --list-type string "[top_panel_screen0]"
gconftool-2 --set /apps/panel/toplevels/top_panel_screen0/background/type --type string "gtk"
# Icons
gsettings set org.gnome.desktop.interface toolbar-style "icons"
gsettings set org.gnome.desktop.interface buttons-have-icons false
gsettings set org.gnome.desktop.interface menus-have-icons true
# Nautilus
gsettings set org.gnome.nautilus.preferences default-folder-viewer "icon-view"
gconftool-2 --set /apps/nautilus/preferences/side_pane_view --type string "NautilusPlacesSidebar"
gsettings set org.gnome.nautilus.preferences sort-directories-first true
gconftool-2 --set /apps/nautilus/preferences/start_with_location_bar --type boolean true
gsettings set org.gnome.nautilus.preferences always-use-location-entry false
gconftool-2 --set /apps/nautilus/preferences/start_with_sidebar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_status_bar --type boolean true
gconftool-2 --set /apps/nautilus/preferences/start_with_toolbar --type boolean true
# Compositing manager
gconftool-2 --set /apps/metacity/general/compositing_manager --type boolean true
# Fonts
gsettings set org.gnome.desktop.interface font-name "Lucida Grande Medium 9"
gsettings set org.gnome.desktop.interface document-font-name "Lucida Grande Medium 9"
gsettings set org.gnome.desktop.interface monospace-font-name "Lucida Console Semi-Condensed 10"
gsettings set org.gnome.nautilus.desktop font "Lucida Grande Medium 9"
gconftool-2 --set /apps/metacity/general/titlebar_font --type string "Lucida Grande Medium 10"
# Terminal
gconftool-2 --set /apps/gnome-terminal/global/use_menu_accelerators --type boolean false
gconftool-2 --set /apps/gnome-terminal/profiles/Default/background_color --type string "#000000000000"
gconftool-2 --set /apps/gnome-terminal/profiles/Default/background_darkness --type float 0.95
gconftool-2 --set /apps/gnome-terminal/profiles/Default/background_type --type string "transparent"
gconftool-2 --set /apps/gnome-terminal/profiles/Default/foreground_color --type string "#AAAAAAAAAAAA"
gconftool-2 --set /apps/gnome-terminal/profiles/Default/scrollback_unlimited --type boolean true
gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_theme_background --type boolean false
gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_theme_colors --type boolean false
# Sound
echo "Setting up sound theme..."
gsettings set org.gnome.desktop.sound theme-name "macbuntu"
gsettings set org.gnome.desktop.sound input-feedback-sounds true
gsettings set org.gnome.desktop.sound event-sounds true
#gconftool-2 --set /desktop/gnome/sound/enable_esd --type boolean true

# Plymouth theme
echo "Setting up Plymouth theme..."
sudo update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/Paw-Ubuntu/paw-ubuntu.plymouth 100
sudo update-alternatives --install /lib/plymouth/themes/default.plymouth default.plymouth /lib/plymouth/themes/Paw-OSX/paw-osx.plymouth 100
# Paw-OSX as default
sudo update-alternatives --set default.plymouth /lib/plymouth/themes/Paw-OSX/paw-osx.plymouth
# Update
sudo update-initramfs -u


echo "Finishing installation..."
echo "$UBUVER-$VERSION" > $MACUBUNTUHOME/current
OLD="$MACUBUNTUHOME/Precise-1.0"
rm -rf $OLD
sleep 10

echo ""
echo "$MACUBUNTU installation complete! Have fun :)"

echo "Featured"
echo " * Firefox theme Vfox3_Basic and MacOSX Theme"
echo " * Thunderbird theme Leopard Mail-Default-Aqua"
echo " * Chrome theme GTK Leopard Chrome Theme"
echo ""
echo "Do you want to see and install [Y/n]?"
read ans
case "$ans" in
	n*|N*) ;;
	*)
	d="/usr/share/applications/firefox.desktop"
	if [ -f "$d" ]; then
		s=`ps | grep firefox`
		echo $s
		if [ ! -n "$s" ]; then
			firefox &
			sleep 10
		fi
		`firefox -new-tab https://addons.mozilla.org/en-US/firefox/addon/11227/ https://addons.mozilla.org/en-US/firefox/addon/12782/ https://addons.mozilla.org/en-US/thunderbird/addon/6763/` &
# ACE Foxdie looks great but not included - security reason, something wrong with the plugin
# https://addons.mozilla.org/en-US/firefox/addon/6124/ 
# TODO: look at source code, do some tests
	fi
	d="/usr/share/applications/google-chrome.desktop"
	if [ -f "$d" ]; then
		`google-chrome http://eamon63.deviantart.com/art/GTK-Leopard-Chrome-Theme-151975508` &
	fi
	d="/usr/share/applications/chromium-browser.desktop"
	if [ -f "$d" ]; then
		`chromium-browser http://eamon63.deviantart.com/art/GTK-Leopard-Chrome-Theme-151975508` &
	fi
	sleep 10
esac

echo ""
echo "It is recommended that you restart the X server (Control+Alt+Backspace if enabled)"
echo "Positively, if reboot the computer. Restart now?"
echo "Please, press any other key if you want to restart later [y/N]?"
read ans
case "$ans" in
	y*|Y*)
	echo "Rebooting..."
	sudo reboot
	exit 0;
esac

echo "Bye"

else # Tester

echo "Tester..."

fi # End Tester

