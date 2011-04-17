Groucho
-------

Groucho is a Lua implementation of [mustache][1], a logic-less templating
language, using [LPeg][2] (well, [re][3] actually) for the dirty work.

For more information about mustache, check out the [mustache project page][4]
or the [mustache manual][5].

Documentation
-------------

There are comments in the code, if that's what you're asking :)

No, they're not [LuaDoc][6]-compatible (don't let the --- comments fool you :P).
I haven't decided which documentation generator to use yet. LuaDoc doesn't
render the docs the way I like, and I don't know what else is out there, so
I made my own markup for now.

Testing
-------

[telescope][7] looked nice, so I wrote some basic tests, using mainly the
examples in the mustache manual. Should've read the [spec][8] instead...

Usage
-----

groucho exports a function **render**, which takes a template
(a string) and a view (a table), as in the example below:

    local result = groucho.render(
        'aasdas{{a}}dasd{{{asdasd}}}{{&awdas}}', -- the template
        { a = '<a>', asdasd = '<dsadsa>' }))     -- the view

Optionally, it may take a configuration table as an extra parameter:

    local result = groucho.render(
        'aasdas{{a}}dasd{{{asdasd}}}{{&awdas}}', -- the template
        { a = '<a>', asdasd = '<dsadsa>' },      -- the view
        { template_path = '../',
          template_extension = 'mustache' }))    -- the configuration table

The comment on the render function should tell you the nitty-gritty.

groucho also exports the **re** grammar (called **grammar**, appropriately
enough), which has some hooks which need to be filled for the pattern to be
constructed. They are also comment-documented.

To do
-----

* Read the damn specs before getting too code happy
* Set delimiters
* Actual documentation
* Make sure the rockspec makes sense

Why?
----

To be honest, I just wanted an excuse to fool around with **re** :) Learning
about some of the tools available for Lua is just the icing on the cake!


[1]: http://mustache.github.com/
[2]: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
[3]: http://www.inf.puc-rio.br/~roberto/lpeg/re.html
[4]: https://github.com/defunkt/mustache
[5]: http://mustache.github.com/mustache.5.html
[6]: https://github.com/keplerproject/luadoc
[7]: https://github.com/norman/telescope
[8]: https://github.com/mustache/spec