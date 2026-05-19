#!/bin/bash
# =============================================================
#  Istaria: Chronicles of the Gifted — Mod Manager
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

log()   { echo -e "${GREEN}[Istaria Mods]${NC} $1"; }
warn()  { echo -e "${YELLOW}[AVISO/WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO/ERROR]${NC} $1"; exit 1; }
title() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

# --- Check kdialog ---
if ! command -v kdialog &>/dev/null; then
    warn "kdialog not found, using text menu / kdialog não encontrado, usando menu de texto"
    USE_KDIALOG=false
else
    USE_KDIALOG=true
fi

# =============================================================
#  FIND ISTARIA
# =============================================================

find_in_wine() {
    local search_paths=(
        "$HOME/.wine"
        "$HOME/.wine-istaria"
        "$HOME/.local/share/wineprefixes"/*
        "$HOME/Games"/*
        "$HOME/Games/istaria"
        "$HOME/.local/share/lutris/runners/wine"/*
        "$HOME/.var/app/net.lutris.Lutris/data/lutris/runners/wine"/*
    )

    for prefix in "${search_paths[@]}"; do
        local path64="$prefix/drive_c/Program Files (x86)/Istaria"
        local path32="$prefix/drive_c/Program Files/Istaria"
        if [ -d "$path64" ]; then echo "$path64"; return 0; fi
        if [ -d "$path32" ]; then echo "$path32"; return 0; fi
    done
    return 1
}

find_in_lutris() {
    # Lutris stores game paths in its database
    local lutris_paths=(
        "$HOME/Games/istaria"
        "$HOME/Games/Istaria"
        "$HOME/.local/share/lutris/games"
    )
    for path in "${lutris_paths[@]}"; do
        if [ -d "$path" ] && [ -f "$path/jlauncher.exe" ]; then
            echo "$path"
            return 0
        fi
    done
    return 1
}

title "Istaria Mod Manager — by Marlon Alex Andrade"
log "Searching for Istaria / Procurando Istaria..."

WINE_PATH=$(find_in_wine 2>/dev/null || true)
LUTRIS_PATH=$(find_in_lutris 2>/dev/null || true)

# --- Decide which path to use ---
if [ -n "$WINE_PATH" ] && [ -n "$LUTRIS_PATH" ]; then
    # Both found — ask user / Ambos encontrados — perguntar
    warn "Istaria found in both Wine and Lutris / Istaria encontrado no Wine e no Lutris."

    if [ "$USE_KDIALOG" = true ]; then
        ENV_CHOICE=$(kdialog --title "Istaria Mod Manager" \
            --menu "Multiple installations found / Múltiplas instalações encontradas. Choose / Escolha:" \
            "1" "Wine — $WINE_PATH" \
            "2" "Lutris — $LUTRIS_PATH")
        case "$ENV_CHOICE" in
            1) ISTARIA_DIR="$WINE_PATH" ;;
            2) ISTARIA_DIR="$LUTRIS_PATH" ;;
            *) exit 0 ;;
        esac
    else
        echo ""
        echo "  [1] Wine   — $WINE_PATH"
        echo "  [2] Lutris — $LUTRIS_PATH"
        echo ""
        read -rp "Choose / Escolha: " ENV_CHOICE
        case "$ENV_CHOICE" in
            1) ISTARIA_DIR="$WINE_PATH" ;;
            2) ISTARIA_DIR="$LUTRIS_PATH" ;;
            *) exit 0 ;;
        esac
    fi

elif [ -n "$WINE_PATH" ]; then
    ISTARIA_DIR="$WINE_PATH"
    log "Istaria found via Wine / Encontrado via Wine: $ISTARIA_DIR"

elif [ -n "$LUTRIS_PATH" ]; then
    ISTARIA_DIR="$LUTRIS_PATH"
    log "Istaria found via Lutris / Encontrado via Lutris: $ISTARIA_DIR"

else
    # Not found — ask manually / Não encontrado — perguntar manualmente
    warn "Istaria not found automatically / Istaria não encontrado automaticamente."

    if [ "$USE_KDIALOG" = true ]; then
        ISTARIA_DIR=$(kdialog --title "Istaria Mod Manager" \
            --inputbox "Istaria not found. Enter the full path:\nIstaria não encontrado. Informe o caminho completo:" \
            "$HOME/.wine/drive_c/Program Files (x86)/Istaria")
    else
        read -rp "Enter Istaria path / Informe o caminho do Istaria: " ISTARIA_DIR
    fi

    if [ -z "$ISTARIA_DIR" ] || [ ! -d "$ISTARIA_DIR" ]; then
        error "Invalid path / Caminho inválido: $ISTARIA_DIR"
    fi
fi

log "Using / Usando: $ISTARIA_DIR"

# =============================================================
#  MOD: MapPack 5.0
# =============================================================
install_mappack() {
    title "MapPack 5.0"
    MAPPACK_URL="https://istaria-mappack.s3.us-west-2.amazonaws.com/MapPackSyncTool.zip"
    MAPPACK_ZIP="/tmp/MapPackSyncTool.zip"
    MAPPACK_DIR="/tmp/MapPackSyncTool"

    log "Downloading / Baixando MapPackSyncTool..."
    wget -O "$MAPPACK_ZIP" "$MAPPACK_URL" || error "Download failed / Falha no download."

    log "Extracting / Extraindo..."
    mkdir -p "$MAPPACK_DIR"
    unzip -o "$MAPPACK_ZIP" -d "$MAPPACK_DIR"

    log "Running / Executando MapPackSyncTool.exe via Wine..."
    log "Point to your Istaria folder and click Add/Sync"
    log "Aponte para a pasta do Istaria e clique em Add/Sync"

    wine "$MAPPACK_DIR/MapPackSyncTool.exe"

    log "MapPack 5.0 done / concluído!"
    rm -f "$MAPPACK_ZIP"
    rm -rf "$MAPPACK_DIR"
}

remove_mappack() {
    title "Removing MapPack / Removendo MapPack"
    MAPPACK_URL="https://istaria-mappack.s3.us-west-2.amazonaws.com/MapPackSyncTool.zip"
    MAPPACK_ZIP="/tmp/MapPackSyncTool.zip"
    MAPPACK_DIR="/tmp/MapPackSyncTool"

    log "Downloading / Baixando MapPackSyncTool..."
    wget -O "$MAPPACK_ZIP" "$MAPPACK_URL" || error "Download failed / Falha no download."

    mkdir -p "$MAPPACK_DIR"
    unzip -o "$MAPPACK_ZIP" -d "$MAPPACK_DIR"

    log "Running removal / Executando remoção..."
    wine "$MAPPACK_DIR/MapPackSyncTool.exe"

    rm -f "$MAPPACK_ZIP"
    rm -rf "$MAPPACK_DIR"
}

# =============================================================
#  MENU
# =============================================================

if [ "$USE_KDIALOG" = true ]; then
    CHOICE=$(kdialog --title "Istaria Mod Manager" \
        --menu "Select an option / Selecione uma opção:" \
        "1" "Install / Instalar — MapPack 5.0" \
        "2" "Remove / Remover — MapPack 5.0" \
        "3" "Exit / Sair")
    case "$CHOICE" in
        1) install_mappack ;;
        2) remove_mappack ;;
        3) exit 0 ;;
        *) exit 0 ;;
    esac
else
    echo ""
    echo "  [1] Install / Instalar — MapPack 5.0"
    echo "  [2] Remove / Remover — MapPack 5.0"
    echo "  [3] Exit / Sair"
    echo ""
    read -rp "Choose / Escolha: " CHOICE
    case "$CHOICE" in
        1) install_mappack ;;
        2) remove_mappack ;;
        3) exit 0 ;;
        *) exit 0 ;;
    esac
fi

title "Done / Concluído!"
