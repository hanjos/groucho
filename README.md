Groucho
-------

Groucho is a Lua implementation of [mustache][1], a logic-less templating
language, using [LPeg][2] (well, [re][3] actually) for the dirty work.

Documentation
-------------

For more information about mustache, check out the [mustache project page][4]
or the [mustache manual][5].

Usage
-----

groucho exports only a single function **render**, which takes a template
(a string) and a view (a table), as in the example below:

    local result = groucho.render(
        'aasdas{{a}}dasd{{{asdasd}}}{{&awdas}}', -- the template
        { a = '<a>', asdasd = '<dsadsa>' }))     -- the view

To do
-----

* Partial templates
* Set delimiters
* Document
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