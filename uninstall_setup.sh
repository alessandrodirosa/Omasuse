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
echo "🟢 Disinstallazione di NVM e di tutte le versioni di Node.js..."
rm -rf ~/.nvm

# ==========================================
# 3. RIMOZIONE APP FLATPAK E DOCKER
# ==========================================
echo "🛍️ Disinstallazione delle applicazioni Flatpak..."
flatpak uninstall -y \
    com.github.tchx84.Flatseal \
    io.github.flattool.Warehouse \
    org.onlyoffice.desktopeditors \
    it.mijorus.gearlever \
    com.google.Chrome \
    com.mattjakeman.ExtensionManager
flatpak uninstall --unused -y

echo "🐳 Disinstallazione di Docker e spegnimento del servizio..."
sudo systemctl disable --now docker
sudo zypper remove -y docker docker-compose

# ==========================================
# 4. RIMOZIONE VISUAL STUDIO CODE E REPO
# ==========================================
echo "🧑‍💻 Disinstallazione di VS Code..."
sudo zypper remove -y code
rm -rf ~/.vscode ~/.config/Code
sudo zypper removerepo vscode

# ==========================================
# 5. RIMOZIONE TEMI DRACULA E RIPRISTINO GNOME
# ==========================================
echo "🧛‍♂️ Rimozione temi Dracula e file di configurazione GTK4..."
rm -rf ~/.themes/Dracula
rm -rf ~/.icons/Dracula

rm -f ~/.config/gtk-4.0/gtk.css
rm -f ~/.config/gtk-4.0/gtk-dark.css
rm -f ~/.config/gtk-4.0/assets
rm -f ~/.config/assets

echo "🖥️ Ripristino impostazioni di default di GNOME..."
gsettings reset org.gnome.mutter experimental-