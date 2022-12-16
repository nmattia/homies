# Lua Functions

The Lua interpreter will look for packages on the `package.path`. During development the functions can be imported as follows:

```vim
:so " loads the file, then just call the function you need
```

in file, or alternatively reload package:

``` vim
" it's important to prepend since package.path already loads those packages from the baked-in config
:lua package.path = "./neovim/lua/termopylae.lua;" .. package.path
:lua package.loaded.termopylae = nil; require'termopylae'.enter_term()
```

For more info, see the [Neovim Lua documentation](https://neovim.io/doc/user/lua.html)
