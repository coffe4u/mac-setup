#/bin/bash -e

# -----------------------------------------------------------------------------
#    Configuration
#
#    Set configuration options in this section.
#       - Home directory
#       - Hostname
#       - Apps to install
#       - Directories to create
# -----------------------------------------------------------------------------

# Set the full path to your user's home directory
readonly HOMEDIR="/Users/jcoats"

# Set the hostname for the computer
readonly HOSTNAME="dijkstra-node-01"

# Apps to install via Homebrew Package Manager
declare -a BREW_APPS=(
  bash              # Bash Shell
  composer          # Composer PHP package manager
  git               # Git Client
  gh                # GitHub CLI
  nodejs            # Node
  npm               # Node Package Manager
  php               # PHP
  tldr              # Man Pages with practical examples
  vim               # CLI Editor
  wget              # CLI HTTP File Retrieval
)

# GUI Apps to install via Homebrew Package Manager using Cask
declare -a BREW_CASK_APPS=(
  atom                     # Code Editor
  caffeine                 # Prevent Sleep Mode
  clementine               # Music Player
  dashlane                 # Password Manager
  dbschema                 # DB Schema Designer
  diffmerge                # Diff GUI
  docker                   # Docker for Mac
  google-chrome            # Chrome Browser
  google-backup-and-sync   # Google Cloud Storage
  iterm2                   # Terminal
  lastfm                   # Audioscrobbler Client
  libreoffice              # LibreOffice
  lsd		                   # Next Gen ls Command
  lunar                    # Control External Monitor Brightness 
  macdown                  # Markdown Editor
  mark-text                # Mark Text Markdown Editor
  menumeters               # System Graphs in the Toolbar
  musicbrainz-picard       # MP3 Tagger
  mysqlworkbench           # MySQL Workbench
  paw                      # API Tool
  phpstorm                 # PHP IDE
  qlmarkdown               # QuickLook generator for Markdown files
  rectangle                # Resize windows with the keyboard
  rescuetime               # Productivity Tracking
  sequel-ace               # MySQL GUI
  slack                    # Chat/Communication
  soundflower              # Virtual Audio Output Device
  sublime-text             # Text Editor
  tableplus                # MySQL GUI
  tower                    # Git GUI
  transmit                 # File Transfers
  vagrant                  # Virtual Machine Management
  virtualbox               # Virtual Machines
  visual-studio-code       # IDE
  vlc                      # Video Player
)

# Directories to create

declare -a DIRS=(
  $HOMEDIR/.ssh/keys/public     ## SSH Public Key Store
  $HOMEDIR/.ssh/keys/private    ## SSH Private Key Store
  $HOMEDIR/Code                 ## Code Projects
)

# -----------------------------------------------------------------------------
#    End Configuration
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
#    Get Started
# -----------------------------------------------------------------------------

 # --- Prompt to run

# Set continue to false by default
CONTINUE=false
clear

echo "###############################################"
echo ""
echo "   MacOS Configuration and Software installer"
echo ""
echo "###############################################"
echo ""
echo " - Verify you've modified the configuration to"
echo "   suit your needs."
echo " - Some settings will require root. You'll be"
echo "   Prompted for your password."
echo ""
echo "###############################################"
echo "      Are you ready to get started? (y/n)"
read -r response

if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
  echo "OK... Here we go!"
fi

if ! $CONTINUE; then
  exit
fi

# --- Unix Environment

# sudo

echo ""
echo "From here on we need root access. "
echo "Enter your password..."
echo ""

sudo

# Hostname

echo ""
echo "Setting hostname to $HOSTNAME..."
echo ""

sudo scutil --set ComputerName $HOSTNAME
sudo scutil --set HostName $HOSTNAME
sudo scutil --set LocalHostName $HOSTNAME
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string $HOSTNAME

echo "Done."
echo ""

# --- MacOS Updates

echo ""
echo "Installing MacOS updates..."
echo ""

softwareupdate --install --all

echo "Done."
echo ""

# --- GCC/Xcode Tools


echo ""
echo "Checking for Xcode..."
echo ""

if [[ ! -e `which gcc` || ! -e `which gcc-4.2` ]]; then
  echo "Installing Xcode"
  echo ""
  xcode-select --install
fi

echo "Done."
echo ""

# --- MacOS Preferences

echo ""
echo "Setting Mac OS preferences..."
echo ""

# Expand the save and print panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Finder
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowStatusBar -bool true
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
chflags nohidden ~/Library/

# Show battery percentage/time remaining
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
defaults write com.apple.menuextra.battery ShowTime -string "NO"

# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable opening Photos on device plug in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

# Login screen message
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "What is thy bidding, my master?"

# Show all device icons in finder
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Default screenshot format
defaults write com.apple.screencapture type png

# Kill affected applications
for app in Finder Dock; do killall "$app"; done
killall SystemUIServer

echo "Done."
echo ""

# --- Homebrew Package Manger

echo ""
echo "Installing Homebrew..."
echo ""

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Done."
echo ""

echo ""
echo "Installing apps..."
echo ""

brew install ${BREW_APPS[@]}
brew cask install ${BREW_CASK_APPS[@]}
brew cleanup

# --- Firewall

echo ""
echo "Enabling Firewall..."
echo ""

# Enable Filevault
sudo fdesetup enable

echo "Done."
echo ""


# --- Directories

echo ""
echo "Adding custom directories..."
echo ""

for dir in "${DIRS[@]}"
do
  if [ ! -d $dir ]; then
    mkdir -p $dir
  fi
done

echo "Done."
echo ""

# --- Dot Files

echo ""
echo "Cloning .dotfiles repo..."
echo ""

if [ ! -d $HOMEDIR/.dotfiles ]; then
  git clone https://github.com/bad-mushroom/dotfiles.git $HOMEDIR/.dotfiles
  $HOMEDIR/.dotfiles/setup.sh
  source $HOMEDIR/.bashrc
fi

echo "Done."
echo ""


# --- Laravel installer
echo ""
echo "Setting up Laravel installer..."
echo ""

composer global require laravel/installer

echo "Done."
echo ""


# --- Done!

echo ""
echo ""
echo "That's all folks..."
echo ""
echo ""

echo ""
echo ""
echo "Note that some of these changes require a logout/restart to take effect."
echo "You should do that now."
echo ""

find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer"; do
  killall "${app}" > /dev/null 2>&1
done

# Exit root shell
exit
