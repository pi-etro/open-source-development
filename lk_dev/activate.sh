#!/usr/bin/env bash

# environment variables
export LK_DEV_DIR="$HOME/github/open-source-development/lk_dev" # path to testing environment directory
export VM_DIR="${LK_DEV_DIR}/vm" # path to VM directory

# prompt preamble
prompt_preamble='(LK-DEV)'

# colors
GREEN="\e[32m"
PINK="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

# launch Bash shell session w/ env vars defined
echo -e "${GREEN}Entering shell session for Linux Kernel Dev${RESET}"
echo -e "${GREEN}To exit, type 'exit' or press Ctrl+D.${RESET}"
exec bash --rcfile <(echo "source ~/.bashrc; PS1=\"\[${BOLD}\]\[${PINK}\]${prompt_preamble}\[${RESET}\] \$PS1\"")
