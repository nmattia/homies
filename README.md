# Homies

<img src="homies.png" alt="homies" style="width: 200px;"/>

Reproducible set of dotfiles and packages for Linux and macOS

---

Install with `nix run github:nmattia/homies#init`. This will add the homies profile and set up some necessary dotfiles.

The homies will be available in all subsequent shells, including the
customizations (vim with my favorite plugins, tmux with my customized
configuration, etc). See the [introduction blog post][post] for an overview.

[post]: https://nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html

## How-To

Install the package set from GitHub:

```bash
nix profile add github:nmattia/homies
```

Alternatively, install from a local checkout:

```bash
nix profile add
```

Create the supporting dotfiles:

```bash
printf "if [ -f ~/.nix-profile/share/zshrc/zshrc ]; then source ~/.nix-profile/share/zshrc/zshrc; fi\n" >> ~/.zshrc
printf "[include]\n\tpath = ~/.nix-profile/share/git/gitconfig\n" >> ~/.gitconfig

[ -d ~/.config/kitty ] && { echo "cannot create symlink for kitty config dir "; exit 1; }
ln -s ~/.config/kitty ~/.nix-profile/share/kitty
```


When necessary, update the packages:

```shell
nix flake update # update all inputs
nix flake update <input> # update specific input
```

Try out the new packages:

```shell
nix build .#homies
```

Upgrade your system to the new profile when happy:

``` shell
nix profile upgrade homies # or list more with "nix profile list"
```

Install applications:

```
rsync --archive --checksum --delete --chmod=-w ~/.nix-profile/Applications/ ~/Applications/homies-apps/ && chmod -R +w ~/Applications/homies-apps
```

> **Note**
> We copy the app to make sure Spotlight picks it up. Creating a (Finder) alias does work too, but
> the alias is given much lower priority in Spotlight search and the app appears way below e.g.
> online searches, files, etc.

Listing the previous and current configurations:

``` shell
$ nix profile history
```

Deleting old configurations:

``` shell
nix profile wipe-history
```

Ensure builds are sandboxed:
```
# /etc/nix/nix.conf (or /etc/nix/nix.custom.conf, depending on installer)
# /Library: cc is installed in /Library/Developer (and used from /usr/bin
/cc and others)
# /System/Library: needed for system-wide Perl
sandbox-paths = /bin/bash /bin /usr/bin /usr/sbin /sbin /Library /System/Library
sandbox = true
```
