---
layout: post
title:  "🧪🐧 Setting up a test environment for Linux Kernel Development"
date:   2026-02-25 16:20:00 -0300
categories: [linux kernel]
---

### tl;dr

- Create a virtual machine (VM) with extracted kernel and initrd
- `QEMU` to run VMs
- `libvirt` to manage VMs and to automate
- Configure SSH access from the host to the VM
- Fetch the list of modules loaded in the guest kernel

### Commands

```bash
launch_vm_qemu # launch a VM with qemu with the extracted kernel and initrd
create_vm_virsh # create a virsh VM with the extracted kernel and initrd
sudo systemctl start libvirtd && systemctl status libvirtd # start libvirtd and check its status
sudo virsh net-start default && sudo virsh net-list # start default network and list networks
sudo virsh console arm64 # re-attach to the console of the running vm
sudo virsh list --all # list all created VMs
sudo virsh dominfo arm64 # Show detailed information about a vm
sudo virsh start --console arm64 # start a previously created vm
sudo virsh shutdown arm64 # shutdown a vm gracefully
sudo virsh destroy arm64 # force shutdown a vm
sudo virsh undefine arm64 # remove stopped vm
```

### Notes

To keep my `activate.sh` script versioned, I structured my setup as follows:

```
/home
├── lk_dev
│   ├── shared_arm64
│   └── vm
│       ├── arm64_boot
│       │   ├── initrd.img-6.1.0-43-arm64
│       │   └── vmlinuz-6.1.0-43-arm64
│       ├── arm64_img.qcow2
│       └── base_arm64_img.qcow2
└── pietro
    └── github
        └── open-source-development
            └── lk_dev
                └── activate.sh
```

The VMs had to be stored under the `home` directory for virsh access. Note that when creating the `/home/lk_dev`
directory and it's groups, I had to restart the computer, logging out and back in wasn't enough.

The Debian image from the guide wasn't available anymore, so the version used was the [daily version 20260225-2399](http://cdimage.debian.org/cdimage/cloud/bookworm/daily/20260225-2399/debian-12-nocloud-arm64-daily-20260225-2399.qcow2).

> ⚠️ Remember to start `libvirtd` after restarting the computer.
> ```
> sudo systemctl start libvirtd
> systemctl status libvirtd
> ```

The Debian image used doesn't come with SSH installed, so I had to install it manually by running the VM with virsh and then executing:

```bash
sudo apt install update
sudo apt install openssh-server
```
After the setup was completed, I could access the VM successfully with SSH:

```bash
ssh root@192.168.122.135
```

### Reference

[Setting up a test environment for Linux Kernel Dev using QEMU and libvirt](https://flusp.ime.usp.br/kernel/qemu-libvirt-setup/)
