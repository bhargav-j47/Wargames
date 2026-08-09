#!/bin/bash

CTF_SCRIPT="./ctf-script.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ██╗    ██╗ █████╗ ██████╗  ██████╗  █████╗ ███╗   ███╗███████╗"
echo "  ██║    ██║██╔══██╗██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝"
echo "  ██║ █╗ ██║███████║██████╔╝██║  ███╗███████║██╔████╔██║█████╗  "
echo "  ██║███╗██║██╔══██║██╔══██╗██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  "
echo "  ╚███╔███╔╝██║  ██║██║  ██║╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗"
echo "   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝"
echo -e "${NC}"
echo -e "${YELLOW}  CTF Platform • Linux Diary 7.0 • 10 Levels${NC}"
echo

# ── Docker check ─────────────────────────────────
if ! command -v docker >/dev/null 2>&1; then
  echo -e "${RED}[!] Docker is not installed.${NC}"
  echo -e "${YELLOW}[*] Attempting to install Docker (Ubuntu)...${NC}"

  sudo apt update -y
  sudo apt install -y docker.io

  if [ $? -ne 0 ]; then
    echo -e "${RED}[✘] Docker installation failed. Please install Docker manually:${NC}"
    echo "    https://docs.docker.com/engine/install/"
    exit 1
  fi

  echo -e "${GREEN}[✔] Docker installed.${NC}"
fi

# ── Docker service check ──────────────────────────
if ! systemctl is-active --quiet docker 2>/dev/null; then
  echo -e "${YELLOW}[*] Starting Docker service...${NC}"
  sudo systemctl start docker
  sudo systemctl enable docker 2>/dev/null
fi

echo -e "${GREEN}[✔] Docker service is running.${NC}"

# ── User group ─────────────────────────
if ! groups "$USER" 2>/dev/null | grep -q "\bdocker\b"; then
  echo -e "${YELLOW}[*] Adding $USER to docker group (may require re-login)...${NC}"
  sudo usermod -aG docker "$USER" 2>/dev/null
fi

# ── Launch CTF ────────────────────────────────────
echo
if [ -f "$CTF_SCRIPT" ]; then
  chmod +x "$CTF_SCRIPT"
  bash "$CTF_SCRIPT" start
else
  echo -e "${RED}[✘] ctf-script.sh not found. Make sure both scripts are in the same directory.${NC}"
  exit 1
fi
