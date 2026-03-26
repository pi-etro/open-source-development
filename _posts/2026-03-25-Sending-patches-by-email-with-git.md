---
layout: post
title:  "📨 Sending patches by email with git"
date:   2026-03-25 16:20:00 -0300
categories: [linux kernel]
---

### tl;dr

- Running the email proxy
- Configuring git send-email with kw send-patch 
- Testing the setup with kw send-patch

### Commands

```bash
cd ~/github/emailproxy-container
docker compose up --build -d # run the container
docker exec -it emailproxy-container-server-1 /bin/bash # attach to the container terminal
emailproxy --no-gui --external-auth --config-file /app/emailproxy.config # start the email proxy
kw send-patch --send --private --to='<EMAIL-ADDRESS-1>','<EMAIL-ADDRESS-2>' # send the patch, use --simulate to dry-run
```

### Notes

For this tutorial, we started by installing docker and docker-compose following [this guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04).

After editing the config file in the `emailproxy-container` repository clone, we ran the container with the following command:
```bash
docker compose up --build -d
```

After this, we attached the terminal to the container with:
```bash
docker exec -it emailproxy-container-server-1 /bin/bash
```

And then started the email proxy with:
```bash
emailproxy --no-gui --external-auth --config-file /app/emailproxy.config
```

Finally, we sent the email after some configurations to `kw send-patch`:
```bash
kw send-patch --send --private --to='<EMAIL-ADDRESS-1>','<EMAIL-ADDRESS-2>'
```

In this final step, I had some trouble when authenticating my email address. In the end I had to disable ad and tracking
blocker extensions to be able to get the `http://localhost/...` URL.

### Reference

[Sending patches by email with git](https://flusp.ime.usp.br/git/sending-patches-by-email-with-git/)

[Sending patches with git and a USP email](https://flusp.ime.usp.br/git/sending-patches-with-git-and-a-usp-email/)
