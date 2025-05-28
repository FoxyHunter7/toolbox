# Minecraft Dedicated Server

This folder contains a collection of files / custom scripts
I use when hosting a Minecraft server.

I prefer to have things lightweight without sacrificing on
functionality, maintainability or usability.
These scripts are my approach at a dynamic solution 
which can meet all needs.

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
or running `sudo systemctl status minecraft-server`, to see the latest logs
alongside the status of the system service.

![logging-journal-ctl](readme-img/logging-journalctl.png)

## Setup Guide

These scripts should work for both vanilla or modded minecraft.

### Setting up the environment

**1.** Ensure your system is up to date

```shell
# Debian-based systems
sudo apt update && sudo apt upgrade

# RHEL-based systems
sudo dnf update
```

**2.** Create the minecraft user

```shell
sudo useradd -m -d /opt/minecraft-server -s /bin/bash minecraft
```

- `-m` creates the home directory if it doesn't exist.
- `-d` specifies that /opt/minecraft-server should be the home directory
- `-s` set the login shell

By default, because no password was set, the `minecraft` login cannot log in directly with a password.
This is intended, for added security. However, if you find that the user minecraft does have a password or you temporarily set one, you can delete any password set for the `minecraft` user with the following command:

```shell
sudo passwd -d minecraft
```

**3.** Install Java

> [!NOTE]
> It is recommended to always check which version of java best works with the minecraft version you're installing.

Replace the version number with the version you need.

```shell
# Debian-based systems
sudo apt install openjdk-21-jre

# RHEL-based systems
sudo dnf install java-21-openjdk
```

### Installing the server

#### **1.** Switch to the minecraft user

```shell
sudo su - minecraft
```

#### **2.** Download the minecraft: java edition server. 

https://www.minecraft.net/en-us/download/server

You can do so using wget, eg:
```shell
wget https://piston-data.mojang.com/v1/objects/e6ec2f64e6080b9b5d9b471b291c33cc7f509733/server.jar
```

> [!NOTE]
> At this point, you may be installing `forge`, `neoforge`, `fabrice`, ... or other modded server runtimes.
> This documentation does not cover modded specifics, although it's important that the jar file to run the server is called `server.jar`.
> Typically on modded servers you'd place the mod files in a folder named: `mods`

#### **3.** Accepting the EULA

run the `run.sh` script once, this will put in place some more files such as the `server.proprties` and create the `eula.txt`, which you must edit and set to `eula=true`.

### Configure the server

Now is the perfect time to customise and configure the server. Add a server-icon, configure `server.properties`, import an already existing world, ...

Below some sources which may help you in this step:
- https://minecraft.fandom.com/wiki/Server.properties
- https://mctools.org/motd-creator

> [!TIP]
> A server icon can be set by adding an image of 64x64 named: `server-icon.png`

### Add automation scripts _(from this repo)_

Now you can add the scripts from this repo.

Make sure all scripts are executable _(if you haven't added any scripts yourself)_, simply run:

```shell
chmod +x *.sh
```

> [!WARNING]
> This will make all files ending with `.sh` executable.

Alternatibly make every file executable seperatly:

```shell
chmod +x filename.sh
```

Set the server-address, java params & desired alerters in: `runner-config.sh`.  
An alerter could look like: 

```shell
ALERTER_SENDERS=("$SCRIPT_DIR/webhook/discord-embed.sh")
```

### Keeping it alive (systemd)

Lastly we must keep the server alive, although the tmux instance already makes it so it keeps running in the background,
it won't attempt to restart on a crash, neither would it auto-start after a machine reboot.

To accomplish this, we'll write a systemd service:

#### **1.** Exit minecraft user's shell

To write the systemd service, we'll need sudo access.
We'll exit back to the account with which you logged into your linux-machine.

Simply write `exit` to exit out of the minecraft user's shell.

#### **2.** Create minecraft-server.service

The command below will create the systemd service file for the minecraft-server.

Configured to:
- automatically restart the server on failure,
- limit restarts to 6 within a 60-second window,
- halt automatic restarts if that limit is exceeded, requiring manual intervention,
- avoid rapid crash loops and reduce system strain,
- prevent endless restart cycles after repeated failures.


```shell
sudo tee /etc/systemd/system/minecraft-server.service <<EOF
[Unit]
Description=Minecraft Server
After=network.target
StartLimitBurst=6
StartLimitIntervalSec=60

[Service]
User=minecraft
WorkingDirectory=/opt/minecraft-server
ExecStart=/opt/minecraft-server/runner.sh start
ExecStop=/opt/minecraft-server/runner.sh stop
Restart=always
RestartSec=10
SuccessExitStatus=0

[Install]
WantedBy=multi-user.target
EOF
```

#### **3.** Enable the service

Make sure systemd sees your new servcice file, this may not be needed, but is generally considered best-practice.

```shell
sudo systemctl daemon-reload
```

Enable the service. _(this won't run it yet, but enables it, so it will run on boot)_

```shell
sudo systemctl enable minecraft-server.service
```

### Wrapping up

Now that everything is in place, you can start the server by running:

```shell
sudo systemctl start minecraft-server.service
```

To stop or restart the server you can write `stop` or `restart` instead of `start`.  
You can also write `status`, to see the status of the server.

To see the full detailed log of the system service (not minecraft), use journalctl:

```shell
sudo journalctl -xeu minecraft-server.service
```
