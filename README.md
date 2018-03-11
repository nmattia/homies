# Homies

Reproducible set of dotfiles and packages for Linux and macOS

## How-to

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
