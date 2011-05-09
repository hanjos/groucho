package.path = '../src/?.lua;../src/?/init.lua;'..package.path

require 'telescope'
require 'groucho'

-- extracted from https://github.com/mustache/spec, v1.1.2

context('Section', function ()
  context('Basic', function ()
    --[=[
    - name: Truthy
      desc: Truthy sections should have their contents rendered.
      data: { boolean: true }
      template: '"{{#boolean}}This should be rendered.{{/boolean}}"'
      expected: '"This should be rendered."'
    --]=]
    it('Truthy', function ()
      local template = '"{{#boolean}}This should be rendered.{{/boolean}}"'
      local expected = '"This should be rendered."'
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Falsey
      desc: Falsey sections should have their contents omitted.
      data: { boolean: false }
      template: '"{{#boolean}}This should not be rendered.{{/boolean}}"'
      expected: '""'
    --]=]
    it('Falsey', function ()
      local template = '"{{#boolean}}This should not be rendered.{{/boolean}}"'
      local expected = '""'
      local data = { boolean = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Context
      desc: Objects and hashes should be pushed onto the context stack.
      data: { context: { name: 'Joe' } }
      template: '"{{#context}}Hi {{name}}.{{/context}}"'
      expected: '"Hi Joe."'
    --]=]
    it('Context', function ()
      local template = '"{{#context}}Hi {{name}}.{{/context}}"'
      local expected = '"Hi Joe."'
      local data = { context = { name = 'Joe' } }

      assert_equal(groucho.render(template, data), expected)
    end)
    --[=[
    - name: Deeply Nested Contexts
      desc: All elements on the context stack should be accessible.
      data:
        a: { one: 1 }
        b: { two: 2 }
        c: { three: 3 }
        d: { four: 4 }
        e: { five: 5 }
      template: |
        {{#a}}
        {{one}}
        {{#b}}
        {{one}}{{two}}{{one}}
        {{#c}}
        {{one}}{{two}}{{three}}{{two}}{{one}}
        {{#d}}
        {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
        {{#e}}
        {{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
        {{/e}}
        {{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
        {{/d}}
        {{one}}{{two}}{{three}}{{two}}{{one}}
        {{/c}}
        {{one}}{{two}}{{one}}
        {{/b}}
        {{one}}
        {{/a}}
      expected: |
        1
        121
        12321
        1234321
        123454321
        1234321
        12321
        121
        1
    --]=]
    it('Deeply Nested Contexts', function ()
      local template = [[
{{#a}}
{{one}}
{{#b}}
{{one}}{{two}}{{one}}
{{#c}}
{{one}}{{two}}{{three}}{{two}}{{one}}
{{#d}}
{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
{{#e}}
{{one}}{{two}}{{three}}{{four}}{{five}}{{four}}{{three}}{{two}}{{one}}
{{/e}}
{{one}}{{two}}{{three}}{{four}}{{three}}{{two}}{{one}}
{{/d}}
{{one}}{{two}}{{three}}{{two}}{{one}}
{{/c}}
{{one}}{{two}}{{one}}
{{/b}}
{{one}}
{{/a}}
]]
      local expected = [[
1
121
12321
1234321
123454321
1234321
12321
121
1
]]
      local data = {
        a = { one = 1 },
        b = { two = 2 },
        c = { three = 3 },
        d = { four = 4 },
        e = { five = 5 } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: List
      desc: Lists should be iterated; list items should visit the context stack.
      data: { list: [ { item: 1 }, { item: 2 }, { item: 3 } ] }
      template: '"{{#list}}{{item}}{{/list}}"'
      expected: '"123"'
    --]=]
    it('List', function()
      local template = '"{{#list}}{{item}}{{/list}}"'
      local expected = '"123"'
      local data = {
        list = {
          { item = 1 },
          { item = 2 },
          { item = 3 },
        }
      }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Empty List
      desc: Empty lists should behave like falsey values.
      data: { list: [ ] }
      template: '"{{#list}}Yay lists!{{/list}}"'
      expected: '""'
    --]=]
    it('Empty List', function()
      local template = '"{{#list}}Yay lists!{{/list}}"'
      local expected = '""'
      local data = { list = {} }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Doubled
      desc: Multiple sections per template should be permitted.
      data: { bool: true, two: 'second' }
      template: |
        {{#bool}}
        * first
        {{/bool}}
        * {{two}}
        {{#bool}}
        * third
        {{/bool}}
      expected: |
        * first
        * second
        * third
    --]=]
    it('Doubled', function()
      local template = [[
{{#bool}}
* first
{{/bool}}
* {{two}}
{{#bool}}
* third
{{/bool}}
]]
      local expected = [[
* first
* second
* third
]]
      local data = { bool = true, two = 'second' }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Nested (Truthy)
      desc: Nested truthy sections should have their contents rendered.
      data: { bool: true }
      template: "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
      expected: "| A B C D E |"
    --]=]
    it('Nested (Truthy)', function()
      local template = "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
      local expected = "| A B C D E |"
      local data = { bool = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Nested (Falsey)
      desc: Nested falsey sections should be omitted.
      data: { bool: false }
      template: "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
      expected: "| A  E |"
    --]=]
    it('Nested (Falsey)', function()
      local template = "| A {{#bool}}B {{#bool}}C{{/bool}} D{{/bool}} E |"
      local expected = "| A  E |"
      local data = { bool = false }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Context Misses
      desc: Failed context lookups should be considered falsey.
      data: { }
      template: "[{{#missing}}Found key 'missing'!{{/missing}}]"
      expected: "[]"
    --]=]
    it('Context Misses', function()
      local template = "[{{#missing}}Found key 'missing'!{{/missing}}]"
      local expected = "[]"
      local data = {}

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Implicit Iterators', function ()
    --[=[
    - name: Implicit Iterator - String
      desc: Implicit iterators should directly interpolate strings.
      data:
        list: [ 'a', 'b', 'c', 'd', 'e' ]
      template: '"{{#list}}({{.}}){{/list}}"'
      expected: '"(a)(b)(c)(d)(e)"'
    --]=]
    it('Implicit Iterator - String', function()
      local template = '"{{#list}}({{.}}){{/list}}"'
      local expected = '"(a)(b)(c)(d)(e)"'
      local data = { list = { 'a', 'b', 'c', 'd', 'e' } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Implicit Iterator - Integer
      desc: Implicit iterators should cast integers to strings and interpolate.
      data:
        list: [ 1, 2, 3, 4, 5 ]
      template: '"{{#list}}({{.}}){{/list}}"'
      expected: '"(1)(2)(3)(4)(5)"'
    --]=]
    it('Implicit Iterator - Integer', function()
      local template = '"{{#list}}({{.}}){{/list}}"'
      local expected = '"(1)(2)(3)(4)(5)"'
      local data = { list = { 1, 2, 3, 4, 5 } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Implicit Iterator - Decimal
      desc: Implicit iterators should cast decimals to strings and interpolate.
      data:
        list: [ 1.10, 2.20, 3.30, 4.40, 5.50 ]
      template: '"{{#list}}({{.}}){{/list}}"'
      expected: '"(1.1)(2.2)(3.3)(4.4)(5.5)"'
    --]=]
    it('Implicit Iterator - Decimal', function()
      local template = '"{{#list}}({{.}}){{/list}}"'
      local expected = '"(1.1)(2.2)(3.3)(4.4)(5.5)"'
      local data = { list = { 1.10, 2.20, 3.30, 4.40, 5.50 } }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Dotted Names', function ()
    --[=[
    - name: Dotted Names - Truthy
      desc: Dotted names should be valid for Section tags.
      data: { a: { b: { c: true } } }
      template: '"{{#a.b.c}}Here{{/a.b.c}}" == "Here"'
      expected: '"Here" == "Here"'
    --]=]
    it('Dotted Names - Truthy', function()
      local template = '"{{#a.b.c}}Here{{/a.b.c}}" == "Here"'
      local expected = '"Here" == "Here"'
      local data = { a = { b = { c = true } } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Falsey
      desc: Dotted names should be valid for Section tags.
      data: { a: { b: { c: false } } }
      template: '"{{#a.b.c}}Here{{/a.b.c}}" == ""'
      expected: '"" == ""'
    --]=]
    it('Dotted Names - Falsey', function()
      local template = '"{{#a.b.c}}Here{{/a.b.c}}" == ""'
      local expected = '"" == ""'
      local data = { a = { b = { c = false } } }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Dotted Names - Broken Chains
      desc: Dotted names that cannot be resolved should be considered falsey.
      data: { a: { } }
      template: '"{{#a.b.c}}Here{{/a.b.c}}" == ""'
      expected: '"" == ""'
    --]=]
    it('Dotted Names - Broken Chains', function()
      local template = '"{{#a.b.c}}Here{{/a.b.c}}" == ""'
      local expected = '"" == ""'
      local data = { a = {} }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Whitespace Sensitivity', function ()
    --[=[
    - name: Surrounding Whitespace
      desc: Sections should not alter surrounding whitespace.
      data: { boolean: true }
      template: " | {{#boolean}}\t|\t{{/boolean}} | \n"
      expected: " | \t|\t | \n"
    --]=]
    it('Surrounding Whitespace', function()
      local template = " | {{#boolean}}\t|\t{{/boolean}} | \n"
      local expected = " | \t|\t | \n"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)
    
    --[=[
    - name: Internal Whitespace
      desc: Sections should not alter internal whitespace.
      data: { boolean: true }
      template: " | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
      expected: " |  \n  | \n"
    --]=]
    it('Internal Whitespace', function()
      local template = " | {{#boolean}} {{! Important Whitespace }}\n {{/boolean}} | \n"
      local expected = " |  \n  | \n"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Indented Inline Sections
      desc: Single-line sections should not alter surrounding whitespace.
      data: { boolean: true }
      template: " {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
      expected: " YES\n GOOD\n"
    --]=]
    it('Indented Inline Sections', function()
      local template = " {{#boolean}}YES{{/boolean}}\n {{#boolean}}GOOD{{/boolean}}\n"
      local expected = " YES\n GOOD\n"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Lines
      desc: Standalone lines should be removed from the template.
      data: { boolean: true }
      template: |
        | This Is
        {{#boolean}}
        |
        {{/boolean}}
        | A Line
      expected: |
        | This Is
        |
        | A Line
    --]=]
    it('Standalone Lines', function()
      local template = "| This Is\n{{#boolean}}\n|\n{{/boolean}}\n| A Line\n"
      local expected = "| This Is\n|\n| A Line\n"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Indented Standalone Lines
      desc: Indented standalone lines should be removed from the template.
      data: { boolean: true }
      template: |
        | This Is
          {{#boolean}}
        |
          {{/boolean}}
        | A Line
      expected: |
        | This Is
        |
        | A Line
    --]=]
    it('Indented Standalone Lines', function()
      local template = "| This Is\n  {{#boolean}}\n|\n  {{/boolean}}\n| A Line\n"
      local expected = "| This Is\n|\n| A Line\n"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Line Endings
      desc: '"\r\n" should be considered a newline for standalone tags.'
      data: { boolean: true }
      template: "|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
      expected: "|\r\n|"
    --]=]
    it('Standalone Line Endings', function()
      local template = "|\r\n{{#boolean}}\r\n{{/boolean}}\r\n|"
      local expected = "|\r\n|"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Without Previous Line
      desc: Standalone tags should not require a newline to precede them.
      data: { boolean: true }
      template: "  {{#boolean}}\n#{{/boolean}}\n/"
      expected: "#\n/"
    --]=]
    it('Standalone Without Previous Line', function()
      local template = "  {{#boolean}}\n#{{/boolean}}\n/"
      local expected = "#\n/"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)

    --[=[
    - name: Standalone Without Newline
      desc: Standalone tags should not require a newline to follow them.
      data: { boolean: true }
      template: "#{{#boolean}}\n/\n  {{/boolean}}"
      expected: "#\n/\n"
    --]=]
    it('Standalone Without Previous Line', function()
      local template = "#{{#boolean}}\n/\n  {{/boolean}}"
      local expected = "#\n/\n"
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)

  context('Whitespace Insensitivity', function ()
    --[=[
    - name: Padding
      desc: Superfluous in-tag whitespace should be ignored.
      data: { boolean: true }
      template: '|{{# boolean }}={{/ boolean }}|'
      expected: '|=|'
    --]=]
    it('Standalone Without Previous Line', function()
      local template = '|{{# boolean }}={{/ boolean }}|'
      local expected = '|=|'
      local data = { boolean = true }

      assert_equal(groucho.render(template, data), expected)
    end)
  end)
end)