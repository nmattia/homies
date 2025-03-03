# Homies

<img src="homies.png" alt="homies" style="width: 200px;"/>

Reproducible set of dotfiles and packages for Linux and macOS

---

Install with `nix profile install`. Update your `~/.zshrc`:

``` zsh
if [ -f $HOME/.nix-profile/share/zshrc/zshrc ]; then source $HOME/.nix-profile/share/zshrc/zshrc; fi
```

The homies will be available in all subsequent shells, including the
customizations (vim with my favorite plugins, tmux with my customized
configuration, etc). See the [introduction blog post][post] for an overview.

[post]: https://nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html

## How-To

Installing the package set:

``` shell
$ nix profile install
```

Updating the packages:

```shell
$ nix flake update # alternative: nix flake lock --update-input <my-input>
```

Try out the new packages:

```shell
$ nix develop
```

Upgrading to the new profile:

``` shell
$ nix profile upgrade homies # or list more with "nix profile list"
```

Syncing apps for Spotlight indexing:

```
$ rsync --archive --checksum --delete --chmod=-w ~/.nix-profile/Applications/ ~/Applications/homies-apps/ && chmod -R +w ~/Applications/homies-apps && codesign --remove-signature ~/Applications/homies-apps/kitty.app && codesign --force --deep --sign - ~/Applications/homies-apps/kitty.app
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
$ nix profile wipe-history
```

Ensure build is sandboxed:
```
# /etc/nix/nix.conf
build-users-group = nixbld
# /Library: cc is installed in /Library/Developer (and used from /usr/bin
/cc and others)
# /System/Library: needed for system-wide Perl
sandbox-paths = /bin/bash /bin /usr/bin /usr/sbin /Library /System/Library
sandbox = true
```
