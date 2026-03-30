#!/bin/bash

# ==========================================
# 0. WELCOME BANNER
# ==========================================
GREEN='\033[1;32m'
PURPLE='\033[1;35m'
NC='\033[0m'

clear
echo -e "${PURPLE}=======================================================${NC}"
echo -e "${GREEN}           🦇 TUMBLEWEED DRACULA SETUP 🦇${NC}"
echo -e "${PURPLE}=======================================================${NC}"
echo ""
sleep 2

# ==========================================
# 1. SYSTEM UPDATE
# ==========================================
echo "🔄 Starting system update..."
sudo zypper dup -y
echo ""

# ==========================================
# 2. BASE PACKAGES INSTALLATION
# ==========================================
echo "📦 Installing packages from official repositories..."
sudo zypper in -y flatpak zsh fastfetch htop opi curl jq git unzip dconf gh gutenprint
echo ""

# ==========================================
# 3. FLATPAK & APPS CONFIGURATION
# ==========================================
echo "🛍️ Configuring Flathub and installing applications..."
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
    com.github.tchx84.Flatseal \
    io.github.flattool.Warehouse \
    it.mijorus.gearlever \
    com.google.Chrome \
    com.mattjakeman.ExtensionManager
echo ""

# ==========================================
# 4. VISUAL STUDIO CODE INSTALLATION
# ==========================================
echo "🧑‍💻 Adding repository and installing Visual Studio Code..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo -f https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper refresh
sudo zypper in -y code

echo "🧩 Installing VS Code extensions..."
VSCODE_EXTS=(
    "dracula-theme.theme-dracula"
    "PKief.material-icon-theme"
    "christian-kohler.path-intellisense"
    "streetsidesoftware.code-spell-checker"
    "formulahendry.auto-rename-tag"
    "usernamehw.errorlens"
    "kito94.intellij-idea-keybindings"
    "ms-azuretools.vscode-docker"
    "ms-vscode-remote.remote-containers"
    "alefragnani.project-manager"
    "waderyan.gitblame"
    "mhutchie.git-graph"
    "donjayamanne.githistory"
    "letmaik.git-tree-compare"
    "jamiewhitlam.changelists"
    "arturock.gitstash"
)

for ext in "${VSCODE_EXTS[@]}"; do
    echo "   -> Installing: $ext"
    code --install-extension "$ext" --force
done
echo ""

# ==========================================
# 5. DOCKER & DOCKER COMPOSE INSTALLATION
# ==========================================
echo "🐳 Installing Docker following the openSUSE guide..."
sudo zypper in -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
echo ""

# ==========================================
# 6. MULTIMEDIA CODECS & GNOME TWEAKS
# ==========================================
echo "🎵 Installing multimedia codecs (Press 'Y' if prompted by opi)..."
opi codecs
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
echo ""

# ==========================================
# 7. DRACULA THEME DOWNLOAD & SETUP (GTK3 & GTK4)
# ==========================================
echo "🧛‍♂️ Installing Dracula GTK Theme and Icons..."
mkdir -p ~/.themes ~/.icons ~/.config/gtk-4.0

curl -sL https://github.com/dracula/gtk/archive/master.zip -o /tmp/dracula-theme.zip
unzip -q /tmp/dracula-theme.zip -d /tmp/
rm -rf ~/.themes/Dracula
mv /tmp/gtk-master ~/.themes/Dracula

curl -sL https://github.com/m4thewz/dracula-icons/archive/main.zip -o /tmp/dracula-icons.zip
unzip -q /tmp/dracula-icons.zip -d /tmp/
rm -rf ~/.icons/Dracula
mv /tmp/dracula-icons-main ~/.icons/Dracula

gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
gsettings set org.gnome.desktop.interface icon-theme "Dracula"
gsettings set org.gnome.desktop.interface accent-color 'purple'

rm -f ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/assets ~/.config/assets
ln -sf ~/.themes/Dracula/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.themes/Dracula/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
ln -sf ~/.themes/Dracula/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -sf ~/.themes/Dracula/assets ~/.config/assets

rm /tmp/dracula-theme.zip /tmp/dracula-icons.zip
echo ""

# ==========================================
# 8. GNOME EXTENSIONS DOWNLOAD & SETUP
# ==========================================
echo "🧩 Starting GNOME extensions configuration..."
gsettings set org.gnome.shell disable-user-extensions false

GNOME_VERSION=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)
EXTENSIONS=(
    "dash-to-dock@micxgx.gmail.com"
    "Vitals@CoreCoding.com"
    "kiwimenu@kemma"
    "appindicatorsupport@rgcjonas.gmail.com"
    "caffeine@patapon.info"
    "gsconnect@andyholmes.github.io"
    "clipboard-indicator@tudmotu.com"
    "blur-my-shell@aunetx"
    "user-theme@gnome-shell-extensions.gcampax.github.com"
)

mkdir -p ~/.local/share/gnome-shell/extensions/
for UUID in "${EXTENSIONS[@]}"; do
    API_RESPONSE=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=${UUID}&shell_version=${GNOME_VERSION}")
    DOWNLOAD_PATH=$(echo "$API_RESPONSE" | jq -r '.download_url // empty')
    if [ -n "$DOWNLOAD_PATH" ]; then
        curl -sL "https://extensions.gnome.org${DOWNLOAD_PATH}" -o "/tmp/gnome_ext.zip"
        gnome-extensions install --force "/tmp/gnome_ext.zip" > /dev/null 2>&1
        rm "/tmp/gnome_ext.zip"
    fi
done

EXT_LIST=$(ls -1 ~/.local/share/gnome-shell/extensions/ 2>/dev/null | awk '{print "\x27"$1"\x27"}' | paste -sd "," -)
if [ -n "$EXT_LIST" ]; then
    gsettings set org.gnome.shell enabled-extensions "[$EXT_LIST]"
    dconf write /org/gnome/shell/extensions/user-theme/name "'Dracula'"
fi
echo ""

# ==========================================
# 9. OH MY ZSH & PLUGINS SETUP
# ==========================================
echo "🐚 Installing and configuring Oh My Zsh..."
rm -rf ~/.oh-my-zsh
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM}/plugins/you-should-use

sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)/' ~/.zshrc

echo "alias c='code'" >> ~/.zshrc
echo "alias d='docker'" >> ~/.zshrc
echo "alias dc='docker-compose'" >> ~/.zshrc

sudo usermod -s $(which zsh) $USER
echo ""

# ==========================================
# 10. NVM & NODE.JS LTS INSTALLATION
# ==========================================
echo "🟢 Installing NVM and Node.js (Latest LTS)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# Append NVM standard configuration to the end of .zshrc
cat << 'EOF' >> ~/.zshrc

# NVM Configuration
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF

# Load NVM in the current environment to install Node right now
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts
nvm alias default 'lts/*'
echo ""

echo -e "${PURPLE}=======================================================${NC}"
echo -e "${GREEN}   🎉 SETUP COMPLETE! Please restart your computer.${NC}"
echo -e "${PURPLE}=======================================================${NC}"
echo ""
echo -e "${GREEN}  📝 MANUAL STEPS AFTER RESTART:${NC}"
echo ""
echo -e "  🎨 VS Code Theme:"
echo -e "     1. Open VS Code"
echo -e "     2. Press Ctrl+Shift+P → 'Preferences: Color Theme'"
echo -e "     3. Select ${PURPLE}Dracula${NC}"
echo ""
echo -e "  🗂️  VS Code Icons:"
echo -e "     1. Press Ctrl+Shift+P → 'Preferences: File Icon Theme'"
echo -e "     2. Select ${PURPLE}Material Icon Theme${NC}"
echo ""
echo -e "${PURPLE}=======================================================${NC}"
