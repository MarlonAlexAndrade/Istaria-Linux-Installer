#!/bin/bash
# =============================================================
#  Istaria: Chronicles of the Gifted — Performance Optimizer
#  Supported: Ubuntu/Debian, Arch Linux, Fedora
#  Author: Marlon Alex Andrade
# =============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()   { echo -e "${GREEN}[Istaria Optimizer]${NC} $1"; }
warn()  { echo -e "${YELLOW}[AVISO/WARN]${NC} $1"; }
error() { echo -e "${RED}[ERRO/ERROR]${NC} $1"; exit 1; }
title() { echo -e "\n${BLUE}========================================${NC}"; echo -e "${BLUE} $1${NC}"; echo -e "${BLUE}========================================${NC}\n"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ISTARIA_DIR=""
WINE_PREFIX=""

# =============================================================
#  DETECTAR DISTRO
# =============================================================
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
}

# =============================================================
#  INSTALAR PACOTE
# =============================================================
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
            warn "Cannot auto-install $pkg / Não foi possível instalar $pkg automaticamente"
            ;;
    esac
}

# =============================================================
#  ENCONTRAR ISTARIA
# =============================================================
find_all_istaria() {
    local results=()
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
        [ -d "$prefix" ] || continue
        local path64="$prefix/drive_c/Program Files (x86)/Istaria"
        local path32="$prefix/drive_c/Program Files/Istaria"
        if [ -d "$path64" ]; then results+=("$path64|$prefix"); fi
        if [ -d "$path32" ]; then results+=("$path32|$prefix"); fi
    done

    printf '%s\n' "${results[@]}"
}

# =============================================================
#  SELECIONAR INSTALAÇÃO
# =============================================================
select_installation() {
    title "Searching / Procurando Istaria..."
    mapfile -t ALL_RESULTS < <(find_all_istaria)

    if [ ${#ALL_RESULTS[@]} -eq 0 ]; then
        error "Istaria not found / Istaria não encontrado. Install the game first / Instale o jogo primeiro."
    fi

    if [ ${#ALL_RESULTS[@]} -gt 1 ]; then
        echo ""
        warn "Multiple installations found / Múltiplas instalações encontradas:"
        echo ""
        for i in "${!ALL_RESULTS[@]}"; do
            local ipath
            ipath=$(echo "${ALL_RESULTS[$i]}" | cut -d'|' -f1)
            echo "  [$((i+1))] $ipath"
        done
        echo "  [0] Back / Voltar"
        echo ""
        read -rp "Choose / Escolha: " CHOICE
        [ "$CHOICE" = "0" ] && return 1
        SELECTED="${ALL_RESULTS[$((CHOICE-1))]}"
    else
        SELECTED="${ALL_RESULTS[0]}"
    fi

    ISTARIA_DIR=$(echo "$SELECTED" | cut -d'|' -f1)
    WINE_PREFIX=$(echo "$SELECTED" | cut -d'|' -f2)
    log "Using / Usando: $ISTARIA_DIR"
    return 0
}

# =============================================================
#  INSTALAR DXVK
# =============================================================
install_dxvk() {
    title "Installing DXVK / Instalando DXVK"

    if [ -f "$SCRIPT_DIR/dxvk/x32/d3d9.dll" ] && [ -f "$SCRIPT_DIR/dxvk/x64/d3d9.dll" ]; then
        log "Using bundled DXVK / Usando DXVK incluso..."
        cp "$SCRIPT_DIR/dxvk/x32/d3d9.dll" "$WINE_PREFIX/drive_c/windows/syswow64/d3d9.dll"
        cp "$SCRIPT_DIR/dxvk/x64/d3d9.dll" "$WINE_PREFIX/drive_c/windows/system32/d3d9.dll"
    else
        log "Downloading latest DXVK / Baixando DXVK mais recente..."
        local dxvk_version
        dxvk_version=$(curl -s "https://api.github.com/repos/doitsujin/dxvk/releases/latest" | grep tag_name | cut -d'"' -f4 | tr -d 'v')

        if [ -z "$dxvk_version" ]; then
            warn "Could not fetch DXVK / Não foi possível baixar o DXVK"
            return
        fi

        local dxvk_url="https://github.com/doitsujin/dxvk/releases/download/v${dxvk_version}/dxvk-${dxvk_version}.tar.gz"
        local dxvk_tmp="/tmp/dxvk-${dxvk_version}.tar.gz"

        wget -O "$dxvk_tmp" "$dxvk_url" || { warn "DXVK download failed / Falha no download"; return; }

        mkdir -p "/tmp/dxvk-extract"
        tar -xf "$dxvk_tmp" -C /tmp/dxvk-extract/
        WINEPREFIX="$WINE_PREFIX" /tmp/dxvk-extract/dxvk-*/setup_dxvk.sh install || warn "DXVK setup failed"

        rm -f "$dxvk_tmp"
        rm -rf /tmp/dxvk-extract
    fi

    log "DXVK installed / DXVK instalado!"
}

# =============================================================
#  CONFIGURAR THREADS DXVK
# =============================================================
configure_dxvk_threads() {
    title "Configuring DXVK threads / Configurando threads DXVK"

    local total_threads
    total_threads=$(nproc)
    local dxvk_threads=$(( total_threads / 2 ))
    [ "$dxvk_threads" -lt 1 ] && dxvk_threads=1

    log "CPU threads: $total_threads — DXVK threads: $dxvk_threads (CPU/2)"

    local dxvk_conf="$ISTARIA_DIR/dxvk.conf"
    [ -f "$dxvk_conf" ] && sed -i '/dxvk.numAsyncThreads/d' "$dxvk_conf"
    echo "dxvk.numAsyncThreads = $dxvk_threads" >> "$dxvk_conf"

    log "dxvk.conf updated / atualizado: numAsyncThreads = $dxvk_threads"
}




# =============================================================
#  APLICAR OTIMIZAÇÕES
# =============================================================
apply_optimizations() {
    title "Applying Optimizations / Aplicando Otimizações"

    select_installation || return

    install_dxvk
    configure_dxvk_threads

    title "Done / Concluído!"
    log "Restart Istaria to apply changes / Reinicie o Istaria para aplicar as mudanças"
    echo ""
    read -rp "Press ENTER to continue / Pressione ENTER para continuar..."
}

# =============================================================
#  MENU PRINCIPAL
# =============================================================
detect_distro

while true; do
    clear
    title "Istaria Performance Optimizer — by Marlon Alex Andrade"
    echo -e "  Optimizes Istaria for better performance on Linux."
    echo -e "  Otimiza o Istaria para melhor desempenho no Linux.\n"
    echo "  [1] Apply optimizations / Aplicar otimizações"
    echo "  [2] Exit / Sair"
    echo ""
    read -rp "Choose / Escolha: " MAIN_CHOICE

    case "$MAIN_CHOICE" in
        1) apply_optimizations ;;
        2) exit 0 ;;
        *) warn "Invalid option / Opção inválida" ;;
    esac
done
