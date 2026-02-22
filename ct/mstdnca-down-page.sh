#!/usr/bin/env bash
# mstdn.ca Maintenance Page - Proxmox LXC Container Creator
#
# One-liner (paste into Proxmox host shell — no clone needed):
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/ChadOhman/mstdnca-down-page/main/ct/mstdnca-down-page.sh)"
#
# What it does:
#   1. Prompts for container settings (or accepts defaults)
#   2. Downloads a Debian 12 template if none exists
#   3. Creates and starts an unprivileged LXC container
#   4. Installs nginx + PHP 8.2-FPM inside the container
#   5. Deploys index.html and scores.php
#   6. Prints the container IP and access URL

set -euo pipefail

# ---------------------------------------------------------------------------
# Source
# ---------------------------------------------------------------------------
GITHUB_RAW="https://raw.githubusercontent.com/ChadOhman/mstdnca-down-page/main"
TMPDIR_WORK="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_WORK"' EXIT

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
YW="\033[33m"
BL="\033[36m"
GN="\033[1;92m"
RD="\033[01;31m"
CL="\033[m"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

msg_info()  { echo -e "${YW}  [INFO]${CL} $1"; }
msg_ok()    { echo -e "  ${CM} $1"; }
msg_warn()  { echo -e "  ${YW}[WARN]${CL} $1"; }
msg_error() { echo -e "  ${CROSS} ${RD}$1${CL}"; exit 1; }

# ---------------------------------------------------------------------------
# Defaults (override interactively below)
# ---------------------------------------------------------------------------
CTID=""
HOSTNAME="mstdn-down-page"
DISK_SIZE="2"
RAM="512"
CPU="1"
BRIDGE="vmbr0"
STORAGE=""
TEMPLATE_STORAGE="local"
UNPRIVILEGED=1
START_ON_BOOT=1

# ---------------------------------------------------------------------------
# Header
# ---------------------------------------------------------------------------
header_info() {
    clear
    echo -e "${BL}
  ╔══════════════════════════════════════════════════╗
  ║   mstdn.ca Maintenance Page — Proxmox LXC Setup  ║
  ╚══════════════════════════════════════════════════╝
${CL}"
}

# ---------------------------------------------------------------------------
# Pre-flight checks
# ---------------------------------------------------------------------------
check_root() {
    [[ $EUID -eq 0 ]] || msg_error "Run this script as root on the Proxmox host."
}

check_proxmox() {
    command -v pct   &>/dev/null || msg_error "pct not found — is this a Proxmox VE host?"
    command -v pvesh &>/dev/null || msg_error "pvesh not found — is this a Proxmox VE host?"
}

check_curl() {
    command -v curl &>/dev/null || msg_error "curl is required but not installed on the Proxmox host."
}

# ---------------------------------------------------------------------------
# Download app files from GitHub to a temp dir on the host
# ---------------------------------------------------------------------------
fetch_files() {
    msg_info "Fetching application files from GitHub..."
    curl -fsSL "${GITHUB_RAW}/index.html"                          -o "${TMPDIR_WORK}/index.html" \
        || msg_error "Failed to download index.html"
    curl -fsSL "${GITHUB_RAW}/scores.php"                          -o "${TMPDIR_WORK}/scores.php" \
        || msg_error "Failed to download scores.php"
    curl -fsSL "${GITHUB_RAW}/install/mstdnca-down-page-install.sh" -o "${TMPDIR_WORK}/install.sh" \
        || msg_error "Failed to download install script"
    chmod +x "${TMPDIR_WORK}/install.sh"
    msg_ok "Files fetched."
}

# ---------------------------------------------------------------------------
# Storage selection
# ---------------------------------------------------------------------------
select_storage() {
    local storages
    storages=$(pvesm status --content rootdir 2>/dev/null | awk 'NR>1 {print $1}') || true

    if [[ -z "$storages" ]]; then
        msg_error "No storage found that supports container rootfs. Create one in the Proxmox UI first."
    fi

    STORAGE=$(echo "$storages" | head -1)

    echo -e "\n${YW}  Storages available for container rootfs:${CL}"
    echo "$storages" | sed 's/^/    /'
    read -r -p "  Storage [${STORAGE}]: " input
    STORAGE="${input:-$STORAGE}"
}

# ---------------------------------------------------------------------------
# Interactive configuration
# ---------------------------------------------------------------------------
configure() {
    CTID=$(pvesh get /cluster/nextid 2>/dev/null || echo "100")

    echo -e "${YW}\n  Container configuration (press Enter to accept defaults):${CL}\n"
    read -r -p "  Container ID   [${CTID}]:          " input; CTID="${input:-$CTID}"
    read -r -p "  Hostname       [${HOSTNAME}]:  " input; HOSTNAME="${input:-$HOSTNAME}"
    read -r -p "  Disk size (GB) [${DISK_SIZE}]:             " input; DISK_SIZE="${input:-$DISK_SIZE}"
    read -r -p "  RAM (MB)       [${RAM}]:           " input; RAM="${input:-$RAM}"
    read -r -p "  CPU cores      [${CPU}]:             " input; CPU="${input:-$CPU}"
    read -r -p "  Network bridge [${BRIDGE}]:         " input; BRIDGE="${input:-$BRIDGE}"
    select_storage
    echo ""
}

# ---------------------------------------------------------------------------
# Template
# ---------------------------------------------------------------------------
get_template() {
    local template
    template=$(pveam list "$TEMPLATE_STORAGE" 2>/dev/null \
        | awk '/debian-12/ {print $1}' \
        | sort -V \
        | tail -1) || true

    if [[ -z "$template" ]]; then
        msg_info "No Debian 12 template found. Downloading..."
        pveam update &>/dev/null

        local available
        available=$(pveam available --section system 2>/dev/null \
            | awk '/debian-12-standard/ {print $2}' \
            | sort -V \
            | tail -1) || true

        [[ -n "$available" ]] || msg_error "Could not find a Debian 12 template. Run 'pveam update' manually and retry."

        msg_info "Downloading ${available}..."
        pveam download "$TEMPLATE_STORAGE" "$available" \
            || msg_error "Template download failed."

        template=$(pveam list "$TEMPLATE_STORAGE" 2>/dev/null \
            | awk '/debian-12/ {print $1}' \
            | sort -V \
            | tail -1)
    fi

    [[ -n "$template" ]] || msg_error "Template still not found after download attempt."
    echo "$template"
}

# ---------------------------------------------------------------------------
# Container creation
# ---------------------------------------------------------------------------
create_ct() {
    local template
    template=$(get_template)

    msg_info "Creating container ${CTID} (${HOSTNAME}) from ${template}..."

    pct create "$CTID" "$template" \
        --hostname     "$HOSTNAME" \
        --storage      "$STORAGE" \
        --rootfs       "${STORAGE}:${DISK_SIZE}" \
        --memory       "$RAM" \
        --cores        "$CPU" \
        --net0         "name=eth0,bridge=${BRIDGE},ip=dhcp,ip6=auto" \
        --unprivileged "$UNPRIVILEGED" \
        --features     nesting=1 \
        --ostype       debian \
        --onboot       "$START_ON_BOOT" \
        --timezone     host \
        --start        1

    msg_ok "Container ${CTID} created and started."
}

# ---------------------------------------------------------------------------
# Wait for the container's init to settle before running commands
# ---------------------------------------------------------------------------
wait_for_boot() {
    msg_info "Waiting for container to boot..."
    local attempts=30
    while [[ $attempts -gt 0 ]]; do
        local state
        state=$(pct exec "$CTID" -- systemctl is-system-running 2>/dev/null || echo "starting")
        if [[ "$state" == "running" || "$state" == "degraded" ]]; then
            msg_ok "Container is ready (state: ${state})."
            return 0
        fi
        sleep 2
        ((attempts--))
    done
    msg_warn "Container boot check timed out — continuing anyway."
}

# ---------------------------------------------------------------------------
# Deploy application
# ---------------------------------------------------------------------------
deploy_app() {
    msg_info "Pushing application files into container..."
    pct exec "$CTID" -- mkdir -p /var/www/maintenance
    pct push "$CTID" "${TMPDIR_WORK}/index.html" /var/www/maintenance/index.html
    pct push "$CTID" "${TMPDIR_WORK}/scores.php"  /var/www/maintenance/scores.php
    msg_ok "Application files pushed."

    msg_info "Running install script inside container..."
    pct push "$CTID" "${TMPDIR_WORK}/install.sh" /tmp/mstdn-install.sh
    pct exec "$CTID" -- bash /tmp/mstdn-install.sh
    msg_ok "Install script completed."
}

# ---------------------------------------------------------------------------
# Print result
# ---------------------------------------------------------------------------
print_result() {
    local ip
    ip=$(pct exec "$CTID" -- hostname -I 2>/dev/null | awk '{print $1}') \
        || ip="(check with: pct exec ${CTID} -- hostname -I)"

    echo ""
    echo -e "${GN}  ╔══════════════════════════════════════════════════╗
  ║              Deployment complete!               ║
  ╚══════════════════════════════════════════════════╝${CL}"
    echo ""
    echo -e "  Container ID : ${YW}${CTID}${CL}"
    echo -e "  Hostname     : ${YW}${HOSTNAME}${CL}"
    echo -e "  IP address   : ${YW}${ip}${CL}"
    echo -e "  Access URL   : ${BL}http://${ip}/${CL}"
    echo ""
    echo -e "  ${YW}Tips:${CL}"
    echo -e "    • Open a shell in the CT : pct enter ${CTID}"
    echo -e "    • Stop the CT            : pct stop  ${CTID}"
    echo -e "    • Destroy the CT         : pct destroy ${CTID} --destroy-unreferenced-disks 1"
    echo -e "    • Point your reverse proxy at http://${ip}/ to serve the maintenance page."
    echo ""
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
header_info
check_root
check_proxmox
check_curl
fetch_files
configure
create_ct
wait_for_boot
deploy_app
print_result
