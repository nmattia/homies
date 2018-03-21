# Homies

<img src="homies.png" alt="homies" style="width: 200px;"/>

Reproducible set of dotfiles and packages for Linux and macOS

---

This is the setup I use on all my machines. The installation process is very
simple and allows me to get up and running on any new machine in a matter of
seconds. The following is run on a pristine Ubuntu machine with `curl`
available:

``` shell
$ # install Nix
$ curl https://nixos.org/nix/install | sh
$ echo ". $HOME/.nix-profile/etc/profile.d/nix.sh" >> .bashrc # optional
$ . $HOME/.nix-profile/etc/profile.d/nix.sh
$ # pull the homies
$ nix-shell -p git --run 'git clone http://github.com/nmattia/homies'
$ # applying the config
$ cd homies; nix-env -f default.nix -i --remove-all
$ echo 'if [ -x "$(command -v bashrc)" ]; then $(bashrc); fi' >> .bashrc
```

The homies will be available in all subsequent shells, including the
customizations (vim with my favorite plugins, tmux with my customized
configuration, etc). See the [introduction blog post][post] for an overview.

[post]: http://nmattia.com/posts/2018-03-21-nix-reproducible-setup-linux-macos.html

## How-To

Trying out the package set:

``` shell
$ nix-shell --pure
```

Installing the package set:

``` shell
$ nix-env -f default.nix -i --remove-all
```

Listing the currently installed packages:

``` shell
$ nix-env -q
```

Listing the previous and current configurations:

``` shell
$ nix-env --list-generations
```

Rolling back to the previous configuration:

``` shell
$ nix-env --rollback
```

Deleting old configurations:

``` shell
$ nix-env --delete-generations [3 4 9 | old | 30d]
```
