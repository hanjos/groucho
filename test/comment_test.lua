package.path = '../src/?.lua;'..package.path

require 'telescope'
require 'groucho'

context('Comments', function ()
  it('ignores comments', function ()
    local base = [[
<h1>Today{{! ignore me }}.</h1>
* {{name}}{{! look at me! I'm plenty of fun! :DDD }}
* {{age}}{{! Hey, don't ignore me, man! That's not cool... }}
* {{company}}{{! Screw you, man! I've got friends... They're in my head... }}
* {{{company}}}{{! YEAH, I CUT MYSELF! THAT'S YOUR FAULT! THAT'S SOCIETY'S FAULT!1!}}]]

    local expected = [[
<h1>Today.</h1>
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
end)