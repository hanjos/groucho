package.path = '../src/?.lua;'..package.path

local write = io.write
local groucho = require 'groucho'

do
  write 'Testing partials... '
  local base = [[
<h2>Names</h2>
{{#names}}
  {{> fixtures/user}}
{{/names}}
]]


  local expected = [[
<h2>Names</h2>
<strong>Alice</strong>
<strong>Bob</strong>
<strong>Cindy</strong>
]]

  local actual = groucho.render(
    base,
    { names = {
        { name = 'Alice' },
        { name = 'Bob' },
        { name = 'Cindy' },
      } })
  assert(expected == actual, 'Expected "'..expected..'", got "'..actual..'"')
  print 'OK!'
end

do
  write 'Testing partials with rewritten defaults... '
  local base = [[
<h2>Names</h2>
{{#names}}
  {{> next_more}}
{{/names}}
]]

  local expected = [[
<h2>Names</h2>
<more>Alice</more>
<more>Bob</more>
<more>Cindy</more>
]]

  local actual = groucho.render(
    base,
    { names = {
        { argh = 'Alice' },
        { argh = 'Bob' },
        { argh = 'Cindy' },
      } },
    { template_path = 'fixtures',
      template_extension = '', })
  assert(expected == actual, 'Expected "'..expected..'", got "'..actual..'"')
  print 'OK!'
end

