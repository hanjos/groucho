Groucho
-------

Groucho is a Lua implementation of [mustache][1], a logic-less templating
language, using [LPeg][2] (well, [re][3] actually) for the dirty work.

For more information about mustache, check out the [mustache project page][4]
or the [mustache manual][5].

Documentation
-------------

There are comments in the code, if that's what you're asking :)

No, they're not [LuaDoc][6]-compatible (don't let the `---` comments fool you :P).
I haven't decided which documentation generator to use yet. LuaDoc doesn't
render the docs the way I like, and I don't know what else is out there, so
I made my own markup for now.

Testing
-------

[telescope][7] looked nice, so I converted the mustache [specs][8] to telescope
tests. **tsc** is expected to be called from the test directory.

Usage
-----

The comment on the **render** function should tell you the nitty-gritty, but
for the TL;DR crowd:

groucho exports a function **render**, which takes a template
(a string) and a context (a table), as in the example below:

```lua
local result = groucho.render(
  'aasdas{{a}}dasd{{{asdasd}}}{{&awdas}}', -- the template
  { a = '<a>', asdasd = '<dsadsa>' }))     -- the context
```
Optionally, it may take a configuration table as an extra parameter:

```lua
local result = groucho.render(
  'aasdas{{a}}dasd{{{asdasd}}}{{&awdas}}', -- the template
  { a = '<a>', asdasd = '<dsadsa>' },      -- the context
  { template_path = '../',
    template_extension = 'mustache' }))    -- the configuration table
```

The result is the template with its variables resolved against the context.

groucho also exports the **re** grammar (called **grammar**, appropriately
enough), which has some hooks which need to be filled for the pattern to be
constructed. They are also comment-documented.

To do
-----

* Set delimiters
* What to do with the documentation?
* Make sure the rockspec makes sense

Why?
----

To be honest, I just wanted an excuse to fool around with **re** :)


[1]: http://mustache.github.com/
[2]: http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html
[3]: http://www.inf.puc-rio.br/~roberto/lpeg/re.html
[4]: https://github.com/defunkt/mustache
[5]: http://mustache.github.com/mustache.5.html
[6]: https://github.com/keplerproject/luadoc
[7]: https://github.com/norman/telescope
[8]: https://github.com/mustache/spec