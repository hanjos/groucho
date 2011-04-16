package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

context('Partials', function ()
  it('handles simple partials', function ()
    local base = [[
<h2>Names</h2>
{{#names}}
  {{> fixtures/user}}
{{/names}}]]

    local expected = [[
<h2>Names</h2>
<strong>Alice</strong>
<strong>Bob</strong>
<strong>Cindy</strong>]]

    local actual = groucho.render(
      base,
      { names = {
          { name = 'Alice' },
          { name = 'Bob' },
          { name = 'Cindy' },
        } })
    
    assert_equal(expected, actual)
  end)

  it('handles partials with rewritten defaults', function ()
    local base = [[
<h2>Names</h2>
{{#names}}
  {{> next_more}}
{{/names}}]]

    local expected = [[
<h2>Names</h2>
<more>Alice</more>
<more>Bob</more>
<more>Cindy</more>]]

    local actual = groucho.render(
      base,
      { names = {
          { argh = 'Alice' },
          { argh = 'Bob' },
          { argh = 'Cindy' },
        } },
      { template_path = 'fixtures',
        template_extension = '', })
    
    assert_equal(expected, actual)
  end)

  it('handles partials inside partials', function ()
    local base = [[
<h2>Names</h2>
{{#names}}
  {{> first}}
{{/names}}]]

    local expected = [[
<h2>Names</h2>
<b>sbrubbles</b>
<i>Alice</i>
<b>sbrubbles</b>
<i>Bob</i>
<b>sbrubbles</b>
<i>Cindy</i>]]

    local actual = groucho.render(
      base,
      { names = {
          { name = 'Alice', title = '<b>sbrubbles</b>' },
          { name = 'Bob', title = '<b>sbrubbles</b>' },
          { name = 'Cindy', title = '<b>sbrubbles</b>' },
        }, },
      { template_path = 'fixtures',
        template_extension = '', })

    assert_equal(expected, actual)
  end)
end)