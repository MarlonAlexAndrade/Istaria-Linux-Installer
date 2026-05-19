#!/bin/bash
# =============================================================
#  Istaria: Chronicles of the Gifted — Linux Installer
#  Supported: Ubuntu/Debian, Arch Linux, Fedora
#
#  Author: Marlon Alex Andrade
# =============================================================

set -e

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()    { echo -e "${GREEN}[Istaria]${NC} $1"; }
warn()   { echo -e "${YELLOW}[AVISO]${NC} $1"; }
error()  { echo -e "${RED}[ERRO]${NC} $1"; exit 1; }
title()  { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

# --- Detect distro ---
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        error "Could not detect Linux distribution."
    fi
    log "Distro detected / Distribuição detectada: $DISTRO"
}

# --- Install generic package ---
install_package() {
    local pkg=$1
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get install -y "$pkg"
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -S --noconfirm "$pkg"
            ;;
        fedora|rhel|centos)
            sudo dnf install -y "$pkg"
            ;;
        *)
            error "Unsupported distribution: $DISTRO"
            ;;
    esac
}

# --- Update repositories ---
update_repos() {
    log "Updating repositories / Atualizando repositórios..."
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)
            sudo apt-get update -y
            ;;
        arch|manjaro|endeavouros)
            sudo pacman -Sy
            ;;
        fedora|rhel|centos)
            sudo dnf check-update -y || true
            ;;
    esac
}

# --- Check and install Wine ---
check_wine() {
    title "Verificando Wine"
    if command -v wine &>/dev/null; then
        log "Wine already installed / Wine já instalado: $(wine --version)"
    else
        warn "Wine not found / Wine não encontrado. Installing / Instalando..."
        case "$DISTRO" in
            ubuntu|debian|linuxmint|pop)
                sudo dpkg --add-architecture i386
                sudo apt-get update -y
                sudo apt-get install -y wine wine32 wine64 winetricks
                ;;
            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm wine winetricks
                ;;
            fedora|rhel|centos)
                sudo dnf install -y wine winetricks
                ;;
        esac
        log "Wine installed successfully / Wine instalado com sucesso."
    fi
}

# --- Check and install Winetricks ---
check_winetricks() {
    if ! command -v winetricks &>/dev/null; then
        warn "Winetricks not found / Winetricks não encontrado. Installing / Instalando..."
        install_package winetricks
    else
        log "Winetricks already installed / Winetricks já instalado."
    fi
}

# --- Check and install Java (native Linux) ---
check_java() {
    title "Verificando Java"
    if command -v java &>/dev/null; then
        log "Java already installed / Java já instalado: $(java -version 2>&1 | head -1)"
    else
        warn "Java not found / Java não encontrado. Installing Java 21 / Instalando Java 21..."
        case "$DISTRO" in
            ubuntu|debian|linuxmint|pop)
                sudo apt-get install -y openjdk-21-jre
                ;;
            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm jre21-openjdk
                ;;
            fedora|rhel|centos)
                sudo dnf install -y java-21-openjdk
                ;;
        esac
        log "Java installed successfully / Java instalado com sucesso."
    fi
}

# --- Check and install basic dependencies ---
check_dependencies() {
    title "Verificando dependências básicas"
    for cmd in wget curl; do
        if ! command -v "$cmd" &>/dev/null; then
            warn "$cmd not found. Installing..."
            install_package "$cmd"
        else
            log "$cmd OK"
        fi
    done
}

# --- Download Istaria installer ---
download_istaria() {
    title "Baixando Istaria"
    INSTALLER_URL="https://istaria-install.s3.amazonaws.com/setup.exe"
    LAUNCHER_URL="https://istaria-install.s3.amazonaws.com/setup_launcher.exe"
    INSTALLER_PATH="/tmp/istaria_setup.exe"
    LAUNCHER_PATH="/tmp/istaria_setup_launcher.exe"

    if [ -f "$INSTALLER_PATH" ]; then
        warn "Installer already exists / Instalador já existe em /tmp, skipping / pulando download."
    else
        log "Downloading game installer / Baixando instalador do jogo (Full Game ~5GB)..."
        wget --progress=bar:force -O "$INSTALLER_PATH" "$INSTALLER_URL" || \
            error "Failed to download / Falha ao baixar instalador. Check your connection / Verifique sua conexão."
        log "Game download complete / Download do jogo concluído."
    fi

}

# --- Install Istaria via Wine ---
install_istaria() {
    title "Instalando Istaria"
    log "Iniciando instalador Windows via Wine..."
    log "Follow the on-screen instructions / Siga as instruções na tela (Next → Next → Finish)"
    wine /tmp/istaria_setup.exe
    # Default Wine installation directory
    ISTARIA_DIR="$HOME/.wine/drive_c/Program Files/Istaria"
    if [ ! -d "$ISTARIA_DIR" ]; then
        # Try alternative path
        ISTARIA_DIR="$HOME/.wine/drive_c/Program Files (x86)/Istaria"
    fi

    if [ ! -d "$ISTARIA_DIR" ]; then
        warn "Installation directory not found / Diretório de instalação não encontrado automaticamente."
        read -rp "Enter the path where Istaria was installed / Informe o caminho onde o Istaria foi instalado: " ISTARIA_DIR
    fi

    log "Istaria installed at / Istaria instalado em: $ISTARIA_DIR"
    export ISTARIA_DIR
}

# --- Install dependencies via Winetricks ---
install_wine_deps() {
    title "Instalando dependências Windows (via Winetricks)"
    log "Installing / Instalando vcrun2005 (Visual C++ 2005)..."
    winetricks -q vcrun2005 || warn "vcrun2005 failed / falhou, continuing / continuando..."

    log "Installing / Instalando corefonts..."
    winetricks -q corefonts || warn "corefonts failed / falhou, continuing / continuando..."

    log "Installing / Instalando DirectPlay..."
    winetricks -q directplay || warn "directplay failed / falhou, continuing / continuando..."

    log "Installing / Instalando vcrun2008 (Visual C++ 2008)..."
    winetricks -q vcrun2008 || warn "vcrun2008 failed / falhou, continuing / continuando..."

    log "Installing / Instalando DirectX 9..."
    winetricks -q d3dx9 || warn "d3dx9 failed / falhou, continuing / continuando..."

    log "Installing / Instalando Java 8 inside Wine / dentro do Wine (required for launcher / necessário para o launcher)..."
    JAVA8_PATH="/tmp/java8-installer.msi"
    if [ ! -f "$JAVA8_PATH" ]; then
        log "Fetching latest Java 8 URL from Adoptium API / Buscando URL mais recente do Java 8..."
        JAVA8_URL=$(curl -s "https://api.adoptium.net/v3/assets/latest/8/hotspot?architecture=x86-32&image_type=jre&os=windows&vendor=eclipse"             | grep -o '"link":"[^"]*\.msi"' | head -1 | cut -d'"' -f4)

        if [ -z "$JAVA8_URL" ]; then
            warn "Could not fetch latest Java 8 URL, using fallback / Usando URL de fallback..."
            JAVA8_URL="https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u412-b08/OpenJDK8U-jre_x86-32_windows_hotspot_8u412b08.msi"
        else
            log "Latest Java 8 found / Java 8 mais recente encontrado: $JAVA8_URL"
        fi

        wget -O "$JAVA8_PATH" "$JAVA8_URL" || warn "Java 8 download failed / falhou, continuing / continuando..."
    fi
    if [ -f "$JAVA8_PATH" ]; then
        wine msiexec /i "$JAVA8_PATH" /quiet || warn "Java 8 install failed / instalação falhou, continuing / continuando..."
    fi

    log "Windows dependencies installed / Dependências Windows instaladas."
}

# --- Create launch script ---
create_launcher_sh() {
    title "Criando launcher"
    LAUNCHER="$HOME/.local/bin/istaria.sh"
    mkdir -p "$HOME/.local/bin"

    cat > "$LAUNCHER" <<EOF
#!/bin/bash
# Launcher - Istaria: Chronicles of the Gifted
# Author: Marlon Alex Andrade
ISTARIA_DIR="${ISTARIA_DIR}"
cd "\$ISTARIA_DIR"
# launcher2.jar requires Java 8 - use Wine's Java 8
wine "\$ISTARIA_DIR/jlauncher.exe"
EOF

    chmod +x "$LAUNCHER"
    log "Launcher created at / Launcher criado em: $LAUNCHER"
}

# --- Install game icon ---
install_icon() {
    ICON_SRC="$(cd "$(dirname "$0")" && pwd)/istaria-icon.png"
    ICON_DEST="$HOME/.local/share/icons/istaria-icon.png"
    mkdir -p "$HOME/.local/share/icons"
    if [ -f "$ICON_SRC" ]; then
        cp "$ICON_SRC" "$ICON_DEST"
        log "Icon installed at / Ícone instalado em: $ICON_DEST"
    else
        warn "istaria-icon.png not found / não encontrado na mesma pasta do script."
    fi
}


# --- Cleanup ---
cleanup() {
    log "Cleaning up temporary files / Limpando arquivos temporários..."
    rm -f /tmp/istaria_setup.exe /tmp/java8-installer.exe
}

# =============================================================
#  MAIN EXECUTION
# =============================================================

clear
title "Instalador do Istaria: Chronicles of the Gifted"
echo -e "  This script will install Istaria on your Linux.
  Este script irá instalar o Istaria no seu Linux."
echo -e "  Supported / Suportado: Ubuntu, Debian, Arch, Fedora\n"
echo -e "  ${BLUE}Author / Autor: Marlon Alex Andrade${NC}\n"
echo -e "  ${YELLOW}Sudo password may be required / Senha sudo pode ser solicitada durante a instalação.${NC}\n"
read -rp "Press ENTER to start or Ctrl+C to cancel / Pressione ENTER para começar ou Ctrl+C para cancelar..."

detect_distro
update_repos
check_dependencies
check_wine
check_winetricks
check_java
download_istaria
install_wine_deps
install_istaria
install_icon
create_launcher_sh
cleanup

title "Instalação concluída!"
log "To play / Para jogar: click the / clique no 'Istaria' shortcut on your desktop / atalho na sua área de trabalho"
log "Or run / Ou execute: ~/.local/bin/istaria.sh"
echo ""
