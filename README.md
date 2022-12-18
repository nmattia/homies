# Homies

<img src="homies.png" alt="homies" style="width: 200px;"/>

Reproducible set of dotfiles and packages for Linux and macOS

---

Install with `nix profile install`. Make sure to update your `.bashrc` or `.bash_profile`:

``` shell
$ echo 'if [ -x "$(command -v bashrc)" ]; then $(bashrc); fi' >> ~/.bashrc
```
The homies will be available in all subsequent shells, including the
customizations (vim with my favorite plugins, tmux with my customized
configuration, etc). See the [introduction blog post][post] for an overview.

[post]: http://nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html

## Fonts

Make sure to [install](https://www.nerdfonts.com/font-downloads) a font with
icons (e.g. Inconsolata) in iterm2 and tell iterm2 to "Use powerline glyphs".

## How-To

Installing the package set:

``` shell
$ nix profile install
```

Upgrading:

``` shell
$ nix profile upgrade X # find X with "nix profile list"
```

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
sandbox-paths = /bin/bash /bin /usr/bin
sandbox = true
```
