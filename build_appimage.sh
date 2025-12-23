#!/bin/bash
# ===========================================
# HIMNARIO ADVENTISTA - BUILD SCRIPT
# Para Linux Mint (sin snap)
# ===========================================

set -e

APP_NAME="HimnarioAdventista"
VERSION="1.0.0"
FLUTTER_VERSION="3.27.1"

echo "============================================"
echo "  HIMNARIO ADVENTISTA - Build Script"
echo "  Para Linux Mint"
echo "============================================"

# Guardar directorio del proyecto
PROJECT_DIR="$(pwd)"

# 1. Verificar/Instalar dependencias del sistema
echo ""
echo "[1/6] Instalando dependencias del sistema..."
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev wget libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly

# 2. Verificar Flutter
echo ""
echo "[2/6] Verificando Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "Flutter no está instalado. Descargando..."
    
    # Descargar Flutter SDK directamente
    cd ~
    if [ ! -d "flutter" ]; then
        wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
        tar xf flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
        rm flutter_linux_${FLUTTER_VERSION}-stable.tar.xz
    fi
    
    # Agregar permanentemente al PATH
    if ! grep -q "flutter/bin" ~/.bashrc; then
        echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
    fi
    
    echo "Flutter instalado en ~/flutter"
fi

# Asegurar que Flutter está en el PATH
export PATH="$PATH:$HOME/flutter/bin"

# Volver al directorio del proyecto
cd "$PROJECT_DIR"

flutter --version

# 3. Habilitar Linux desktop
echo ""
echo "[3/6] Habilitando Linux desktop support..."
flutter config --enable-linux-desktop

# 4. Obtener dependencias
echo ""
echo "[4/6] Obteniendo dependencias del proyecto..."
flutter pub get

# 5. Construir para Linux
echo ""
echo "[5/6] Construyendo para Linux (release)..."
flutter build linux --release

# 6. Crear instalación completa
echo ""
echo "[6/6] Creando instalación..."

INSTALL_DIR="$HOME/HimnarioAdventista"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# Copiar bundle
cp -r build/linux/x64/release/bundle/* "$INSTALL_DIR/"

# Renombrar ejecutable
mv "$INSTALL_DIR/flutter_application_1" "$INSTALL_DIR/HimnarioAdventista"

# Descargar logo oficial
echo "Descargando logo..."
wget -q -O "$INSTALL_DIR/icon.png" "https://www.sdahymnal.net/wp-content/uploads/2021/08/sda-hymnal-logo-cropped.png" || \
wget -q -O "$INSTALL_DIR/icon.png" "https://adventistas.org.pt/wp-content/uploads/2020/06/logo-iasd-simbolo.png" || \
echo "No se pudo descargar logo, usando placeholder"

# Crear script de inicio
cat > "$INSTALL_DIR/iniciar.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")"
./HimnarioAdventista
EOF
chmod +x "$INSTALL_DIR/iniciar.sh"

# Crear archivo .desktop para el menú de aplicaciones
DESKTOP_FILE="$HOME/.local/share/applications/himnario-adventista.desktop"
mkdir -p "$HOME/.local/share/applications"

cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Himnario Adventista
Comment=Himnario Adventista con 613 himnos y audio
Exec=$INSTALL_DIR/HimnarioAdventista
Icon=$INSTALL_DIR/icon.png
Type=Application
Categories=Audio;Music;Education;
Terminal=false
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"

# Crear acceso directo en el escritorio
DESKTOP_SHORTCUT="$HOME/Escritorio/HimnarioAdventista.desktop"
if [ -d "$HOME/Escritorio" ]; then
    cp "$DESKTOP_FILE" "$DESKTOP_SHORTCUT"
    chmod +x "$DESKTOP_SHORTCUT"
    # Marcar como confiable en Linux Mint
    gio set "$DESKTOP_SHORTCUT" metadata::trusted true 2>/dev/null || true
fi

# También probar con Desktop (inglés)
DESKTOP_SHORTCUT_EN="$HOME/Desktop/HimnarioAdventista.desktop"
if [ -d "$HOME/Desktop" ]; then
    cp "$DESKTOP_FILE" "$DESKTOP_SHORTCUT_EN"
    chmod +x "$DESKTOP_SHORTCUT_EN"
    gio set "$DESKTOP_SHORTCUT_EN" metadata::trusted true 2>/dev/null || true
fi

echo ""
echo "============================================"
echo "  ✓ ¡INSTALACIÓN COMPLETADA!"
echo "============================================"
echo ""
echo "  La aplicación está instalada en:"
echo "    $INSTALL_DIR"
echo ""
echo "  Para abrir:"
echo "    • Busca 'Himnario Adventista' en el menú"
echo "    • O doble clic en el icono del Escritorio"
echo "    • O ejecuta: $INSTALL_DIR/HimnarioAdventista"
echo ""
echo "============================================"
