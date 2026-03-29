#!/bin/bash

echo "🧹 INIZIO PULIZIA E RIPRISTINO DEL SISTEMA..."

# ==========================================
# 1. RIPRISTINO SHELL E RIMOZIONE OH MY ZSH
# ==========================================
echo "🐚 Ripristino della shell predefinita a Bash e rimozione Oh My Zsh..."
sudo usermod -s $(which bash) $USER
rm -rf ~/.oh-my-zsh
if [ -f ~/.zshrc.pre-oh-my-zsh ]; then
    mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
else
    rm -f ~/.zshrc
fi

# ==========================================
# 2. RIMOZIONE NVM E NODE.JS
# ==========================================
echo "🟢 Disinstallazione di NVM e Node.js..."
rm -rf ~/.nvm

# ==========================================
# 3. RIMOZIONE APP FLATPAK E DOCKER
# ==========================================
echo "🛍️ Disinstallazione Flatpak e Docker..."
flatpak uninstall -y com.github.tchx84.Flatseal io.github.flattool.Warehouse org.onlyoffice.desktopeditors it.mijorus.gearlever com.google.Chrome com.mattjakeman.ExtensionManager
flatpak uninstall --unused -y
sudo systemctl disable --now docker
sudo zypper remove -y docker docker-compose

# ==========================================
# 4. RIMOZIONE EDITOR (VS CODE E ZED)
# ==========================================
echo "🧑‍💻 Disinstallazione di Visual Studio Code..."
sudo zypper remove -y code
rm -rf ~/.vscode ~/.config/Code
sudo zypper removerepo vscode

echo "⚡ Disinstallazione di Zed..."
rm -rf ~/.local/bin/zed
rm -rf ~/.local/libexec/zed
rm -rf ~/.config/zed
rm -rf ~/.local/share/zed
rm -f ~/.local/share/applications/dev.zed.Zed.desktop

# ==========================================
# 5. RIMOZIONE TEMI DRACULA E RIPRISTINO GNOME
# ==========================================
echo "🧛‍♂️ Rimozione temi Dracula e configurazione GTK4..."
rm -rf ~/.themes/Dracula ~/.icons/Dracula
rm -f ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/assets ~/.config/assets

echo "🖥️ Ripristino impostazioni predefinite di GNOME..."
gsettings reset org.gnome.mutter experimental-features
gsettings reset org.gnome.desktop.interface color-scheme
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.wm.preferences theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface accent-color

# ==========================================
# 6. RIMOZIONE ESTENSIONI GNOME
# ==========================================
echo "🧩 Rimozione estensioni GNOME..."
rm -rf ~/.local/share/gnome-shell/extensions/*
gsettings reset org.gnome.shell enabled-extensions
gsettings reset org.gnome.shell disable-user-extensions
dconf reset /org/gnome/shell/extensions/user-theme/name

echo "=========================================="
echo "✅ RIPRISTINO COMPLETATO! Riavvia il computer."