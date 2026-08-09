#!/bin/bash

# ================================================
#   Wargame CTF Platform - Linux Diary 7.0
# ================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Level Docker images (11 levels: 0-10)
LEVEL_IMAGES=(
  "ghcr.io/neel-1414/linuxdiary7.0:0"
  "ghcr.io/neel-1414/linuxdiary7.0:1"
  "ghcr.io/neel-1414/linuxdiary7.0:2"
  "ghcr.io/neel-1414/linuxdiary7.0:3"
  "ghcr.io/neel-1414/linuxdiary7.0:4"
  "ghcr.io/neel-1414/linuxdiary7.0:5"
  "ghcr.io/neel-1414/linuxdiary7.0:6"
  "ghcr.io/neel-1414/linuxdiary7.0:7"
  "ghcr.io/neel-1414/linuxdiary7.0:8"
  "ghcr.io/neel-1414/linuxdiary7.0:9"
  "ghcr.io/neel-1414/linuxdiary7.0:10"
)

STATE_FILE=".ctf_state"
TOTAL=${#LEVEL_IMAGES[@]}

# ── Trap Ctrl+C ─────────────────────────────────
trap "quit_game" SIGINT

# ── Init state ───────────────────────────────────
if [ ! -f "$STATE_FILE" ]; then
  echo 0 > "$STATE_FILE"
fi

LEVEL=$(cat "$STATE_FILE")

# ── Helpers ──────────────────────────────────────
banner() {
  echo -e "${CYAN}"
  echo '  ██╗    ██╗ █████╗ ██████╗  ██████╗  █████╗ ███╗   ███╗███████╗'
  echo '  ██║    ██║██╔══██╗██╔══██╗██╔════╝ ██╔══██╗████╗ ████║██╔════╝'
  echo '  ██║ █╗ ██║███████║██████╔╝██║  ███╗███████║██╔████╔██║█████╗  '
  echo '  ██║███╗██║██╔══██║██╔══██╗██║   ██║██╔══██║██║╚██╔╝██║██╔══╝  '
  echo '  ╚███╔███╔╝██║  ██║██║  ██║╚██████╔╝██║  ██║██║ ╚═╝ ██║███████╗'
  echo '   ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝'
  echo -e "${NC}"
  echo -e "${YELLOW}  CTF Platform • Linux Diary 7.0 • $TOTAL Levels${NC}"
  echo -e "${BLUE}──────────────────────────────────────────────────────────────────${NC}"
}

stop_container() {
  docker rm -f ctf_container >/dev/null 2>&1
}

save_level() {
  echo "$LEVEL" > "$STATE_FILE"
}

# ── Pull image if missing ────────────────────────
ensure_image() {
  local image=$1
  if ! docker image inspect "$image" >/dev/null 2>&1; then
    echo -e "${YELLOW}⬇  Pulling image: $image${NC}"
    if ! docker pull "$image"; then
      echo -e "${RED}✘ Failed to pull image: $image${NC}"
      return 1
    fi
  fi
  return 0
}

# ── Play a level ─────────────────────────────────
play_level() {
  local IMAGE="${LEVEL_IMAGES[$LEVEL]}"

  clear
  banner
  echo
  echo -e "${GREEN}  Level $LEVEL / $((TOTAL-1))${NC}"
  echo -e "${CYAN}  Image : $IMAGE${NC}"
  echo -e "${YELLOW}  Tip   : Solve the challenge, find the flag, submit it on the Web Frontend http://ldwargames2k26.wcewlug.org   ${NC}"
  echo -e "${YELLOW}  Exit  : Type 'exit' or press Ctrl+D to return to the menu.${NC}"
  echo -e "${BLUE}────────────────────────────────────────────${NC}"
  echo

  stop_container
  ensure_image "$IMAGE" || { show_menu; return; }

  # Run container
  docker run -dit \
    --name ctf_container \
    -e TERM=xterm-256color \
    --user root \
    "$IMAGE" bash >/dev/null

  echo -e "${GREEN}Entering shell...${NC}"
  docker exec -it ctf_container bash

  show_menu
}

# ── Navigation menu ───────────────────────────────
show_menu() {
  stop_container
  echo
  echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
  echo -e "  Exited ${YELLOW}Level $LEVEL${NC} of $((TOTAL-1))"
  echo -e "  ${GREEN}[N]${NC}ext  ${GREEN}[P]${NC}rev  ${GREEN}[S]${NC}elect  ${GREEN}[R]${NC}eplay  ${GREEN}[Q]${NC}uit"
  echo -e "${BLUE}══════════════════════════════════════════════════════════════════${NC}"
  read -p "  > " choice

  case "$choice" in
    N|n) go_next ;;
    P|p) go_prev ;;
    S|s) select_level ;;
    R|r) play_level ;;
    Q|q) quit_game ;;
    *)   echo -e "${RED}Invalid choice.${NC}"; show_menu ;;

  esac
}

# ── Next level ────────────────────────────────────
go_next() {
  local next=$((LEVEL+1))

  if [ $next -ge $TOTAL ]; then
    echo
    echo -e "${GREEN}🎉 Congratulations! You've reached the end of the 10 levels!${NC}"
    echo -e "${CYAN}   Don't forget to submit your flags on the web interface!${NC}"
    quit_game
  fi

  LEVEL=$next
  save_level
  play_level
}

# ── Prev level ────────────────────────────────────
go_prev() {
  if [ $LEVEL -eq 0 ]; then
    echo -e "${RED}Already at Level 0 (first level).${NC}"
    play_level
  else
    LEVEL=$((LEVEL-1))
    save_level
    play_level
  fi
}

# ── Select level ──────────────────────────────────
select_level() {
  echo -e "${CYAN}Available levels: 0 to $((TOTAL-1))${NC}"
  read -p "Enter level number: " lvl_input
  if [[ "$lvl_input" =~ ^[0-9]+$ ]] && [ "$lvl_input" -ge 0 ] && [ "$lvl_input" -lt "$TOTAL" ]; then
    LEVEL=$lvl_input
    save_level
    play_level
  else
    echo -e "${RED}Invalid level number.${NC}"
    show_menu
  fi
}

# ── Quit ──────────────────────────────────────────
quit_game() {
  echo -e "${YELLOW}Quitting CTF. See you next time!${NC}"
  stop_container
  exit 0
}

# ── Entry point ───────────────────────────────────
case "$1" in
  start)  play_level ;;
  next)   go_next ;;
  prev)   go_prev ;;
  quit)   quit_game ;;
  *)
    echo "Usage: $0 {start|next|prev|quit}"
    exit 1
    ;;
esac
