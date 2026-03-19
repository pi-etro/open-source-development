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

- Create an example character device
- Build linux image: `make -C "$IIO_TREE" -j$(nproc) Image.gz modules`
  - This prompts a lot of configuration questions
  - Executed `make -C "$TREE_IIO" olddefconfig` but this failed with "make: the '-C' option requires a non-empty string argument"
- I ended up **not** building the image again and only following the steps for the module installation, and the simple_char driver loaded successfully.
- This was the result, which I think could indicate that the example character device was **not working correctly**:

```bash
root@localhost:~# ./read_prog simple_char_node
Read buffer: ������
root@localhost:~# ./write_prog simple_char_node
Error: 9wrote -1 bytes to buffer
root@localhost:~# ./read_prog simple_char_node
Read buffer: �� ���
root@localhost:~#
```

### Reference

[Introduction to Linux kernel Character Device Drivers](https://flusp.ime.usp.br/kernel/char-drivers-intro/)
