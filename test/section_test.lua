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

  it('handles sections with tables', function ()
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

  it('handles sections with non-false, non-table, non-function values', function ()
    local base = [[
{{#person?}}Hi {{person?}}!{{/person?}}{{#missing}}Insert milk carton here{{/missing}}]]

    local expected = [[Hi Jon!]]

    local context = {
      ['person?'] = "Jon"
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles one-line inverted sections', function ()
    local base = [[
{{#repo}}<b>{{name}}</b>{{/repo}}{{^repo}}No repos :({{/repo}}]]

    local expected = [[No repos :(]]

    local context = {
      repo = {}
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('tests sassy single-line sections', function ()
    local base = '\n {{#full_time}}full time{{/full_time}}\n'

    local expected = '\n full time\n'

    local context = {
      ['full_time'] = true
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('tests padding before section', function ()
    local base = '\t{{#list}}a{{/list}}'

    local expected = '\taa'

    local context = {
      list = { 1, 2 }
    }

    assert_equal(expected, groucho.render(base, context))
  end)
end)