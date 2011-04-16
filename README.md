Groucho
-------

Groucho is a Lua implementation of [mustache][1], a logic-less templating
language, using [LPeg][2] (well, [re][3] actually) for the dirty work.

For more information about mustache, check out the [mustache project page][4]
or the [mustache manual][5].

Documentation
-------------

There are comments in the code, if that's what you're asking :)

No, they're not LuaDoc-compatible (don't let the --- comments fool you :P).
I haven't decided which documentation generator to use yet. LuaDoc doesn't
render the docs the way I like, and I don't know what else is out there, so
I made up my own markup for now.

Usage
-----

groucho exports only a single function **render**, which takes a template
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

To do
-----

* Ascertain that partial templates are working
* Set delimiters
* Documentation
* Actual testing
* Make sure the rockspec makes sense

Why?
----

To be honest, I just wanted an excuse to fool around with re :)


[1]: http://mustache.github.com/
[2]: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
[3]: http://www.inf.puc-rio.br/~roberto/lpeg/re.html
[4]: https://github.com/defunkt/mustache
[5]: http://mustache.github.com/mustache.5.html