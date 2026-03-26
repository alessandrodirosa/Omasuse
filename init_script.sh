#!/bin/bash

# ==========================================
# 1. AGGIORNAMENTO E PULIZIA SISTEMA
# ==========================================
echo "🔄 Avvio aggiornamento sistema e pulizia bloatware..."
sudo zypper dup -y
sudo zypper remove -y evolution gnome-chess gnome-mahjongg gnome-mines gnome-sudoku gnuchess iagno quadrapassel swell-foop lightsoff

# ==========================================
# 2. INSTALLAZIONE PACCHETTI BASE
# ==========================================
echo "📦 Installazione pacchetti da repository ufficiale..."
sudo zypper in -y flatpak zsh fastfetch htop opi curl jq git unzip dconf

# ==========================================
# 3. CONFIGURAZIONE FLATPAK E APP
# ==========================================
echo "🛍️ Configurazione Flathub e installazione applicazioni..."
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
    com.github.tchx84.Flatseal \
    io.github.flattool.Warehouse \
    org.onlyoffice.desktopeditors \
    it.mijorus.gearlever \
    com.google.Chrome \
    com.mattjakeman.ExtensionManager

# ==========================================
# 4. INSTALLAZIONE VISUAL STUDIO CODE E ESTENSIONI
# ==========================================
echo "🧑‍💻 Aggiunta repository e installazione di Visual Studio Code..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper addrepo -f https://packages.microsoft.com/yumrepos/vscode vscode
sudo zypper refresh
sudo zypper in -y code

echo "🧩 Installazione estensioni di VS Code..."
VSCODE_EXTS=(
    "dracula-theme.theme-dracula"
    "PKief.material-icon-theme"
    "WMBGmbH.intellij-git-ext"
)

# Installazione delle estensioni
for ext in "${VSCODE_EXTS[@]}"; do
    code --install-extension "$ext" --force
done

echo "✅ VS Code configurato con successo!"

# ==========================================
# 5. CODECS E TWEAKS DI GNOME
# ==========================================
echo "🎵 Installazione Codecs multimediali..."
opi codecs # (Premi Y se richiesto durante l'esecuzione)

echo "🖥️ Abilitazione ridimensionamento frazionario per Wayland..."
gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

# ==========================================
# 6. DOWNLOAD E SETUP TEMA DRACULA (GTK3 & GTK4)
# ==========================================
echo "🧛‍♂️ Installazione Tema GTK e Icone Dracula..."
mkdir -p ~/.themes ~/.icons ~/.config/gtk-4.0

echo "   -> Scarico Tema GTK e Icone..."
curl -sL https://github.com/dracula/gtk/archive/master.zip -o /tmp/dracula-theme.zip
unzip -q /tmp/dracula-theme.zip -d /tmp/
rm -rf ~/.themes/Dracula
mv /tmp/gtk-master ~/.themes/Dracula

curl -sL https://github.com/m4thewz/dracula-icons/archive/main.zip -o /tmp/dracula-icons.zip
unzip -q /tmp/dracula-icons.zip -d /tmp/
rm -rf ~/.icons/Dracula
mv /tmp/dracula-icons-main ~/.icons/Dracula

echo "   -> Applico il tema e il colore d'accento viola..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
gsettings set org.gnome.desktop.interface icon-theme "Dracula"
gsettings set org.gnome.desktop.interface accent-color 'purple'

echo "   -> Configuro le app GTK4/Libadwaita..."
rm -f ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/assets ~/.config/assets
ln -sf ~/.themes/Dracula/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
ln -sf ~/.themes/Dracula/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
ln -sf ~/.themes/Dracula/gtk-4.0/assets ~/.config/gtk-4.0/assets
ln -sf ~/.themes/Dracula/assets ~/.config/assets

rm /tmp/dracula-theme.zip /tmp/dracula-icons.zip

# ==========================================
# 7. DOWNLOAD E SETUP ESTENSIONI GNOME
# ==========================================
echo "🧩 Inizio configurazione estensioni GNOME..."
gsettings set org.gnome.shell disable-user-extensions false

GNOME_VERSION=$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)
echo "   -> Rilevata GNOME Shell versione: $GNOME_VERSION"

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
    echo "   -> Cerco ed estraggo: $UUID"
    API_RESPONSE=$(curl -s "https://extensions.gnome.org/extension-info/?uuid=${UUID}&shell_version=${GNOME_VERSION}")
    DOWNLOAD_PATH=$(echo "$API_RESPONSE" | jq -r '.download_url // empty')

    if [ -n "$DOWNLOAD_PATH" ]; then
        curl -sL "https://extensions.gnome.org${DOWNLOAD_PATH}" -o "/tmp/gnome_ext.zip"
        gnome-extensions install --force "/tmp/gnome_ext.zip" > /dev/null 2>&1
        rm "/tmp/gnome_ext.zip"
    fi
done

echo "⚙️ Forzatura dell'attivazione delle estensioni nel registro..."
EXT_LIST=$(ls -1 ~/.local/share/gnome-shell/extensions/ 2>/dev/null | awk '{print "\x27"$1"\x27"}' | paste -sd "," -)
if [ -n "$EXT_LIST" ]; then
    gsettings set org.gnome.shell enabled-extensions "[$EXT_LIST]"
    dconf write /org/gnome/shell/extensions/user-theme/name "'Dracula'"
fi

# ==========================================
# 8. SETUP OH MY ZSH E PLUGIN
# ==========================================
echo "🐚 Installazione e configurazione di Oh My Zsh..."
rm -rf ~/.oh-my-zsh
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git ${ZSH_CUSTOM}/plugins/you-should-use

sed -i 's/^plugins=(.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)/' ~/.zshrc
sudo usermod -s $(which zsh) $USER

echo "=========================================="
echo "🎉 SETUP COMPLETATO! Riavvia il computer per applicare tutte le modifiche grafiche e di shell."
