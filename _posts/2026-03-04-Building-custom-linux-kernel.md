---
layout: post
title:  "🏗️ Building and booting a custom Linux kernel with kw"
date:   2026-03-04 15:40:00 -0300
categories: [linux kernel]
---

### tl;dr

- `kw` to develop and build a custom Linux kernel.
- `IIO` Linux kernel tree.
- Linux kernel compilation.
- Booting the custom Linux kernel.

### Commands

```bash
kw ssh # initiate an SSH connection to the default remote
cd "$IIO_TREE" # go to the IIO tree directory
kw build --menu # safely modify `.config` w/ a TUI
kw build # compile Linux kernel from source considering local configurations
kw deploy --modules # only install modules into the VM
```

### Notes

In this class I've installed the [kw](https://github.com/kworkflow/kworkflow) tool to build and boot a custom Linux kernel.
The [IIO](https://git.kernel.org/pub/scm/linux/kernel/git/jic23/iio.git/) (Industrial I/O subsystem) Linux kernel tree was also cloned and built.

The resulting setup for this class was:

```
/home
├── lk_dev
│   ├── iio
│   ├── kw
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

> 📝 `kw` can update itself using the `self-update` command.
> ```bash
> kw self-update # update with master branch
> kw self-update --unstable # update with unstable branch.
> ```

> ⚠️ When a new VM is launched with virsh, update the IP addess in `kw` configuration.
> ```bash
> sudo virsh net-dhcp-leases default
> cd "$IIO_TREE"
> kw remote --add arm64 root@<VM-IP-address> --set-default
> ```

The `kw ssh --get '~/vm_mod_list'` command didn't work for me, so I had to use `scp root@<VM-IP-address>:~/vm_mod_list .`

Sometimes, `sudo virsh shutdown arm64` doesn't work. In these cases I have to force it with `sudo virsh destroy arm64`

### Reference

[Building and booting a custom Linux kernel for ARM using kw](https://flusp.ime.usp.br/kernel/build-linux-for-arm-kw/)
