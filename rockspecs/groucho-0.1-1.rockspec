package = 'groucho'
version = '0.1-1'
source = {
  url = 'git://github.com/hanjos/groucho.git'
}
description = {
  summary = 'Mustache implementation for Lua using LPeg',
  detailed = [[groucho is a small templating library for Lua, 
  mainly an implementation of Mustache (https://github.com/defunkt/mustache) using LPeg.]],
  license = 'MIT/X11',
  homepage = 'http://github.com/hanjos/groucho',
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
      groucho = 'src/groucho/init.lua',
      ['groucho.util'] = 'src/groucho/util.lua',
    }
  }
}