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

  it('handles variables with spaces in the name', function ()
    local base = [[
* {{name of manager}}
* {{age of manager}}
* {{{company name in bold}}}]]

    local expected = [[
* Chris
* 29
* <b>GitHub</b>]]

    local context = {
      ['name of manager'] = "Chris",
      ['age of manager'] = "29",
      ['company name in bold'] = "<b>GitHub</b>",
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('handles variables with non-letter characters in the name', function ()
    local base = [[
* {{name?}}
* {{age!}}
* {{123company_in_bold}}
* {{& =1+2}}]]

    local expected = [[
* Chris
* 29
* &lt;b&gt;GitHub&lt;/b&gt;
* <b>GitHub</b>]]

    local context = {
      ['name?'] = "Chris",
      ['age!'] = "29",
      ['123company_in_bold'] = "<b>GitHub</b>",
      ['=1+2'] = "<b>GitHub</b>",
    }

    assert_equal(expected, groucho.render(base, context))
  end)

  it('converts context values to strings before rendering', function ()
    local base = [[
* {{name}}
* {{age}}
* {{married?}}
* {{  has kids?   }}
* {{has a job?}}]]

    local expected = [[
* Chris
* 29
* true
* false
* ]]

    local context = {
      name = "Chris",
      age = 29,
      ['married?'] = true,
      ['has kids?'] = false,
    }

    assert_equal(expected, groucho.render(base, context))
  end)
end)
