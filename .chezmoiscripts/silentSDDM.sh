# TODO: Is this correct?
info "🖥️ Configuring SDDM Silent Theme..."
paru -S sddm-silent-theme
# TODO: rather pass your own theme and use that
sudo sed -i 's|^ConfigFile=.*|ConfigFile=configs/catppuccin-mocha.conf|' /usr/share/sddm/themes/silent/metadata.desktop
sudo tee /etc/sddm.conf >/dev/null <<EOF
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

[Theme]
Current=silent
EOF

# Set avatar to the current one
./change_avatar.sh "$(whoami)" ~/.face
