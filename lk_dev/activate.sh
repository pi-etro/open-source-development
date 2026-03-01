#!/usr/bin/env bash

# environment variables
export LK_DEV_DIR="/home/lk_dev" # path to testing environment directory
export VM_DIR="${LK_DEV_DIR}/vm" # path to VM directory
export BOOT_DIR="${VM_DIR}/arm64_boot" # path to boot artifacts

# utility functions

# Launches a VM with a custom kernel and `initrd`
function launch_vm_qemu() {
    # DON'T FORGET TO ADAPT THE `-kernel`, `initrd`, AND `-append` LINES!!!
    qemu-system-aarch64 \
        -M virt,gic-version=3 \
        -m 2G -cpu cortex-a57 \
        -smp 2 \
        -netdev user,id=net0 -device virtio-net-device,netdev=net0 \
        -initrd "${BOOT_DIR}/initrd.img-6.1.0-43-arm64" \
        -kernel "${BOOT_DIR}/vmlinuz-6.1.0-43-arm64" \
        -append "loglevel=8 root=/dev/vda2 rootwait" \
        -device virtio-blk-pci,drive=hd \
        -drive if=none,file="${VM_DIR}/arm64_img.qcow2",format=qcow2,id=hd \
        -nographic
}

# Registers and starts a VM with `libvirt`
function create_vm_virsh() {
    # DON'T FORGET TO ADAPT THE `--boot` LINE!!!
    sudo virt-install \
      --name "arm64" \
      --memory 2048 \
      --arch aarch64 --machine virt \
      --osinfo detect=on,require=off \
      --import \
      --features acpi=off \
      --disk path="${VM_DIR}/arm64_img.qcow2" \
      --boot kernel=${BOOT_DIR}/vmlinuz-6.1.0-43-arm64,initrd=${BOOT_DIR}/initrd.img-6.1.0-43-arm64,kernel_args="loglevel=8 root=/dev/vda2 rootwait" \
      --network bridge:virbr0 \
      --graphics none
}

# export functions so they persist in the new Bash shell session
export -f launch_vm_qemu
export -f create_vm_virsh

# prompt preamble
prompt_preamble='(LK-DEV)'

# colors
GREEN="\e[32m"
PINK="\e[35m"
BOLD="\e[1m"
RESET="\e[0m"

# launch Bash shell session w/ env vars and utility functions defined
echo -e "${GREEN}Entering shell session for Linux Kernel Dev${RESET}"
echo -e "${GREEN}To exit, type 'exit' or press Ctrl+D.${RESET}"
exec bash --rcfile <(echo "source ~/.bashrc; PS1=\"\[${BOLD}\]\[${PINK}\]${prompt_preamble}\[${RESET}\] \$PS1\"")
