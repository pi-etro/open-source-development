---
layout: post
title:  "🧩 Linux kernel build configuration and modules"
date:   2026-03-11 16:00:00 -0300
categories: [linux kernel]
---

### tl;dr

- Creating a simple example module
- Creating Linux kernel configuration symbols
- Configuring the Linux kernel build with menuconfig
- Installing Linux kernel modules

### Commands

```bash
make -C "$IIO_TREE" menuconfig # to enable a module in the menuconfig
cd "$IIO_TREE" && kw build --clean # clean artifacts from previous compilations
cd "$IIO_TREE" && kw build # build image and modules
modinfo <module_name> # see information about module of given name
lsmod # @VM list loaded modules
insmod <module_file.ko> # loads module at given location
rmmod <module_name> # unloads module of given name
modprobe <module_name> # loads module of given name and its dependencies 
modprobe -r <module_name> # unloads module of given name
depmod --quick # updates the module dependency list only if a module is added or removed
dmesg | tail # see last logs
```

### Notes

Although the tutorial told us that the entries in the `Kconfig` were in alphabetical order, the order did not appear to be alphabetical.

When installing the Linux kernel modules with `kw`, I got an error saying that `${VM_MOUNT_POINT}` wasn't defined,
to fix this I had to replace it with `${VM_DIR}/arm64_rootfs` for the following command:
```
sudo guestunmount "$VM_MOUNT_POINT"
```

The rest of the tutorial was very clear. By the end, I had a working Linux kernel with the example modules.

### Reference

[Introduction to Linux kernel build configuration and modules](https://flusp.ime.usp.br/kernel/modules-intro/)
