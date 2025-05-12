# Foxy's Toolbox

A repo containing various bits & bobs from architectures & blueprints for myself, to things I make & use that don't stand on their own. Such as marp-themes, scripts, ...

- [Foxy's Toolbox](#foxys-toolbox)
  - [Homelab Resources](#homelab-resources)
    - [Minecraft Server](#minecraft-server)
  - [Architecture Blueprints](#architecture-blueprints)
    - [Vue3](#vue3)
  - [Marp Themes](#marp-themes)

## Homelab Resources

This section contains a variety of scripts and resources, too small to be their own thing, which I use in my homelab.

### Minecraft Server

[`📁 𝗚𝗢𝗧𝗢⠀`](./homelab-resources/minecraft-server/)

This folder contains a collection of files / custom scripts
I use when hosting a Minecraft server.

I prefer to have things lightweight without sacrificing on
functionality, maintainability or usability.
These scripts are my approach at a dynamic solution 
which can meet all needs.

## Architecture Blueprints

This section contains architectural blueprints for various technology stacks. They reflect my personal preferences and the approaches I've found to be most effective, based on my experience and research into design patterns.

> [!IMPORTANT]
> These blueprints are not intended to be definitive solutions or the "one best way" to do things. They reflect my personal preference & ideals.

### Vue3

[`📁 𝗚𝗢𝗧𝗢⠀`](./architecture-blueprints/vue3/)

This architecture improves scalability, maintainability, and testability by separating data management (repositories) from business logic (services). With services and repositories managed through dedicated factories, updates and testing are easier. Keeping the structure modular and flexible ensures the project remains easy to manage and scale without disrupting functionality.

This architecture is ideal for larger, more complex Vue projects, where the added structure helps to keep everything organised. For smaller projects, a simpler approach may be more appropriate.

## Marp Themes

[`📁 𝗚𝗢𝗧𝗢⠀`](./marp-themes/)

Marp themes I made & use *(these are mostly slight alterations or expansions on the default marp theme.)*