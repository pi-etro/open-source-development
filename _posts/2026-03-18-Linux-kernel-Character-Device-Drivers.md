---
layout: post
title:  "📄 Linux kernel Character Device Drivers"
date:   2026-03-18 16:00:00 -0300
categories: [linux kernel]
---

### tl;dr

- Character devices
- Major and Minor Numbers
- File operations
- Bringing device IDs and file operations together
- A character device driver example
- Testing the simple_char driver

### Commands

```bash
cat /proc/devices
stat <file>
mknod <file_name> <type> <major_num> <minor_num>
dmesg -w

@host
aarch64-linux-gnu-gcc write_prog.c -o write_prog
scp write_prog root@<VM-IP-ADDRESS>:~/
@VM
root@localhost:~# ./write_prog simple_char_node

```

### Notes

- **Character devices**
  - Abstraction provided by Linux to support read/write devices with relatively small data transfers (one or a few bytes size).
  - Abstracted as files in the file system and accessed through file access system calls.
  - Example of devices: serial ports, keyboards, mice, etc.
  - Example of character device files: `/dev/ttyS0`, `dev/input/mouse0`, `/dev/kmsg`, `/dev/zero`.

- **Major and Minor Numbers**
  - Files associated with character devices are special types of files.
  - Allow users to interface with devices from the user space.
  - Under the hood, device files are the device drivers that handle the system calls for them. 
  - The association between device files and devices is made with a device ID that consists of two parts: a major and a minor number
  - The device ID (major/minor number) is used to choose which driver to run to support a particular device.

- **File operations**
  - Character device drivers may implement functions to handle file access system calls.
  - The syscalls implemented by a device driver are set into a struct file_operations object.
  - There are several different file operations a character driver can implement.
  - Basic system calls: open, close, read, write.
  - Handled by open, release, read, and write functions stored in struct file_operations objects.

#### Tutorial steps

The following steps were executed to test the simple_char driver. This could be considered a basic example of a workflow
for adding a module to the kernel, building, and installing it.

- Create an example character device
- Enable the device: `make -C "$IIO_TREE" menuconfig`
- Build linux image: `kw build --clean && kw build`
- Install the module:
```bash
mkdir "${VM_DIR}/arm64_rootfs"
sudo guestmount --rw --add "${VM_DIR}/arm64_img.qcow2" --mount /dev/vda2 "${VM_DIR}/arm64_rootfs"
sudo --preserve-env make -C "${IIO_TREE}" INSTALL_MOD_PATH="${VM_DIR}/arm64_rootfs" modules_install
sudo guestunmount "${VM_DIR}/arm64_rootfs"
```
- Start the VM: `sudo virsh start arm64`
- Connect to the VM: `ssh root@$(sudo virsh net-dhcp-leases default | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b')`
- Get information about the module: `modinfo simple_char`
- Load the module: `modprobe simple_char`
- See kernel logs: `dmesg | tail`


Initially the device wasn't writing to the buffer, giving me the following error:
```bash
root@localhost:~# ./write_prog simple_char_node
Error: 9wrote -1 bytes to buffer
```

But this was caused by a misconfiguration with the device interface (`simple_char_node`). By deleting and recreating it
with the correct major number (`cat /proc/devices | grep simp`) I was able to write and read using the device.
```bash
root@localhost:~# ./write_prog simple_char_node
wrote 256 bytes to buffer
root@localhost:~# ./read_prog simple_char_node 
Read buffer: A new message for simple_char.

```

### Reference

[Introduction to Linux kernel Character Device Drivers](https://flusp.ime.usp.br/kernel/char-drivers-intro/)
