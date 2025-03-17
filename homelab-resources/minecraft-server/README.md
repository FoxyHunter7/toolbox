# Minecraft Dedicated Server

This repo contains a collection of files / custom scripts I use when hosting
a Minecraft server.

I prefer to have things lightweight without sacrificing on
functionality, maintainability or usability. These scripts are my approach at a
dynamic solution which can meet all needs.

## Features

### Alerting

- Webhook support
- In game alerts pre-shutdown or potential out of RAM issues.

![discord webhook notifications](readme-img/discord-webhook.png)
![in-game warn chat](readme-img/in-game-warn-chat.png)
![in-game warn actionbar](readme-img/in-game-warn-actionbar.png)

### Self Management / Recovery

These scripts are designed to run using systemd to keep everything alive,
that said, the scripts are designed to:

- Ensures the server is running and attempts restarting before giving up.
- Prevents out of memory issues;
  *stops and restarts the server before system RAM runs out*

### Logging

As mentioned earlier, the server is kept alive using systemd, the sript's logging
can thus be found in that log `sudo journalctl -xue minecraft-server.service`
or running ``sudo systemctl status minecraft-server`, to see the latest logs
alongside the status of the system service.

![logging-journal-ctl](readme-img/logging-journalctl.png)

## Setup Guide

WIP...

Sorry, I have yet to write this part

```s
[Unit]
Description=Minecraft Server
After=network.target
StartLimitBurst=6
StartLimitIntervalSec=60

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft
ExecStart=/opt/minecraft/runner.sh start
ExecStop=/opt/rminecraft/runner.sh stop
Restart=always
RestartSec=10
SuccessExitStatus=0

[Install]
WantedBy=multi-user.target
```