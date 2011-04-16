package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

context('Sections', function ()
  it('handles sections with false values', function ()
    local base = [[
Shown.
{{#nothin}}
  Never shown!
{{/nothin}}]]

    local expected = [[
Shown.
]]

    local context = {
      nothin = false
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles sections with empty lists', function ()
    local base = [[
Shown.
{{#nothin}}
  Never shown!
{{/nothin}}]]

    local expected = [[
Shown.
]]

    local context = {
      nothin = {}
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles sections with non-empty lists', function ()
    local base = [[
{{#repo}}
  <b>{{name}}</b>
{{/repo}}]]

    local expected = [[
<b>resque</b>
<b>hub</b>
<b>rip</b>]]

    local context = {
      repo = {
        { name = "resque" },
        { name = "hub" },
        { name = "rip" },
      }
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles sections with functions', function ()
    local base = [[
{{#wrapped}}
  {{name}} is awesome.
{{/wrapped}}]]

    local expected = [[<b>Willy is awesome.</b>]]

    local context = {
      name = "Willy",
      wrapped = function(text, context, config)
        return "<b>" .. groucho.render(text, context, config) .. "</b>"
      end
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles sections with non-false values', function ()
    local base = [[
{{#person?}}
  Hi {{name}}!
{{/person?}}]]

    local expected = [[Hi Jon!]]

    local context = {
      ['person?'] = { name = "Jon" }
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles inverted sections', function ()
    local base = [[
{{#repo}}
  <b>{{name}}</b>
{{/repo}}{{^repo}}
  No repos :(
{{/repo}}]]

    local expected = [[No repos :(]]

    local context = {
      repo = {}
    }

    assert_equal(expected, groucho.render(base, context))
  end)
end)