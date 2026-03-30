#!/bin/bash

echo "🧹 STARTING SYSTEM CLEANUP AND RESTORE..."
echo ""

# ==========================================
# 1. SHELL RESTORE & OH MY ZSH REMOVAL
# ==========================================
echo "🐚 Restoring default shell to Bash and removing Oh My Zsh..."
sudo usermod -s $(which bash) $USER
rm -rf ~/.oh-my-zsh
if [ -f ~/.zshrc.pre-oh-my-zsh ]; then
    mv ~/.zshrc.pre-oh-my-zsh ~/.zshrc
else
    rm -f ~/.zshrc
fi
echo ""

# ==========================================
# 2. NVM & NODE.JS REMOVAL
# ==========================================
echo "🟢 Uninstalling NVM and Node.js..."
rm -rf ~/.nvm
echo ""

# ==========================================
# 3. FLATPAK APPS & DOCKER REMOVAL
# ==========================================
echo "🛍️ Uninstalling Flatpak applications and Docker..."
flatpak uninstall -y com.github.tchx84.Flatseal io.github.flattool.Warehouse org.onlyoffice.desktopeditors it.mijorus.gearlever com.google.Chrome com.mattjakeman.ExtensionManager
flatpak uninstall --unused -y
sudo systemctl disable --now docker
sudo zypper remove -y docker docker-compose
echo ""

# ==========================================
# 4. VISUAL STUDIO CODE REMOVAL
# ==========================================
echo "🧑‍💻 Uninstalling Visual Studio Code..."
sudo zypper remove -y code
rm -rf ~/.vscode ~/.config/Code
sudo zypper removerepo vscode
echo ""

# ==========================================
# 5. DRACULA THEMES REMOVAL & GNOME RESTORE
# ==========================================
echo "🧛‍♂️ Removing Dracula themes and GTK4 configuration..."
rm -rf ~/.themes/Dracula ~/.icons/Dracula
rm -f ~/.config/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/assets ~/.config/assets

echo "🖥️ Restoring GNOME default settings..."
gsettings reset org.gnome.mutter experimental-features
gsettings reset org.gnome.desktop.interface color-scheme
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.wm.preferences theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface accent-color
echo ""

# ==========================================
# 6. GNOME EXTENSIONS REMOVAL
# ==========================================
echo "🧩 Removing GNOME extensions..."
rm -rf ~/.local/share/gnome-shell/extensions/*
gsettings reset org.gnome.shell enabled-extensions
gsettings reset org.gnome.shell disable-user-extensions
dconf reset /org/gnome/shell/extensions/user-theme/name
echo ""

echo "=========================================="
echo "✅ RESTORE COMPLETE! Restart your computer."
echo "=========================================="
