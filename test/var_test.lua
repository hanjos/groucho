package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

context('Variables', function ()
  it('handles simple variable substitution', function ()
    local base = [[
* {{name}}
* {{age}}
* {{company}}
* {{{company}}}]]

    local expected = [[
* Chris
* 
* &lt;b&gt;GitHub&lt;/b&gt;
* <b>GitHub</b>]]

    local context = {
      name = "Chris",
      company = "<b>GitHub</b>"
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('uses {{& unescaped variable substitution', function ()
    local base = [[
* {{&company}}
* {{{company}}}]]

    local expected = [[
* <b>GitHub</b>
* <b>GitHub</b>]]

    local context = {
      company = "<b>GitHub</b>"
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('has spaces inside delimiters', function ()
    local base = [[
* {{name    }}
* {{ age }}
* {{  company }}
* {{{  company           }}}
* {{& company}}]]

    local expected = [[
* Chris
* 
* &lt;b&gt;GitHub&lt;/b&gt;
* <b>GitHub</b>
* <b>GitHub</b>]]

    local context = {
      name = "Chris",
      company = "<b>GitHub</b>"
    }

    assert_equal(expected, groucho.render(base, context))
  end)
end)
