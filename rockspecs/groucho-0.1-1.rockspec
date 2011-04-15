package = 'groucho'
version = '0.1-1'
description = {
  summary = 'Mustache implementation for Lua using LPeg',
  detailed = [[groucho is a small templating library for Lua, 
  mainly an implementation of Mustache (https://github.com/defunkt/mustache) using LPeg.]],
  license = 'MIT/X11',
  homepage = '',
  maintainer = 'Humberto Anjos (h.anjos@acm.org)',
}
dependencies = {
  'lua >= 5.1',
  'lpeg >= 0.10',
}
build = {
  type = 'none',
  install = {
    lua = {
      'groucho.lua',
    },
  }
}