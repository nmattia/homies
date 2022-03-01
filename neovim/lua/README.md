# Lua Functions

The Lua interpreter will look for packages on the `package.path`. During development the functions can be imported as follows:

``` vim
:lua package.path = package.path .. ";./neovim/lua/get_term.lua"
:lua require'get_term'.get_term()
```

For more info, see the [Neovim Lua documentation](https://neovim.io/doc/user/lua.html)
